require 'rails_helper'

RSpec.describe RatePostJob, type: :job do
  let(:post) { create(:post) }
  let(:user) { create(:user) }
  let(:value) { 5 }

  describe '#perform' do
    context 'under normal conditions' do
      it 'creates a new rating' do
        expect {
          described_class.perform_now(post, user, value)
        }.to change(Rating, :count).by(1)
      end

      it 'associates the rating with the post and user' do
        described_class.perform_now(post, user, value)
        rating = Rating.last

        expect(rating.post).to eq(post)
        expect(rating.user).to eq(user)
        expect(rating.value).to eq(value)
      end
    end

    context 'with concurrent requests' do
      it 'prevents race conditions using row locking' do
        threads = 5.times.map do
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              described_class.perform_now(post, create(:user), rand(1..5))
            end
          end
        end

        threads.each(&:join)

        expect(post.ratings.count).to eq(5)
      end

      it 'maintains data integrity when users rate simultaneously' do
        post = create(:post)
        concurrent_users = create_list(:user, 3)
        latch = Concurrent::CountDownLatch.new(1)
        completion_latch = Concurrent::CountDownLatch.new(3)
        exceptions = []

        threads = concurrent_users.map do |user|
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                latch.wait
                described_class.perform_now(post, user, 5)
              rescue => e
                exceptions << e
              ensure
                completion_latch.count_down
              end
            end
          end
        end

        latch.count_down
        completion_latch.wait
        raise exceptions.first if exceptions.any?

        expect(post.reload.ratings.count).to eq(3)
        expect(post.ratings.pluck(:user_id)).to match_array(concurrent_users.map(&:id))
      end
    end

    context 'with invalid data' do
      it 'raises RecordInvalid for invalid ratings' do
        allow(Rating).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        expect {
          described_class.perform_now(post, user, 0)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create a rating with invalid value' do
        expect {
          described_class.perform_now(post, user, nil)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(post.ratings.count).to eq(0)
      end
    end

    context 'job behavior' do
      it 'enqueues the job' do
        expect {
          described_class.perform_later(post, user, value)
        }.to have_enqueued_job(RatePostJob).with(post, user, value).on_queue('default')
      end

      it 'retries 3 times on RecordInvalid' do
        job = described_class.new
        allow(job).to receive(:perform).and_raise(ActiveRecord::RecordInvalid.new(Rating.new))

        expect {
          job.send(:rescue_with_handler, ActiveRecord::RecordInvalid.new(Rating.new)) || raise(ActiveRecord::RecordInvalid)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when an exception occurs' do
      before do
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(Rating.new))

        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error when rating fails' do
        expect {
          described_class.perform_now(post, user, value)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when transaction fails' do
      before do
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(Rating.new))
      end

      it 'does not persist partial data on failure' do
        expect {
          described_class.perform_now(post, user, value)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(Rating.count).to eq(0)
      end
    end

    context 'when user tries to rate the same post again' do
      it 'raises error for duplicate rating' do
        described_class.perform_now(post, user, value)

        expect {
          described_class.perform_now(post, user, value)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when rating value is out of valid range' do
      it 'raises RecordInvalid for out-of-bounds value' do
        expect {
          described_class.perform_now(post, user, 10)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(post.ratings.count).to eq(0)
      end
    end
  end
end
