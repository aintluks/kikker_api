require 'rails_helper'

# spec/models/post_spec.rb
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:valid_attributes) do
    {
      user: create(:user),
      title: FFaker::Lorem.sentence,
      body: FFaker::Lorem.paragraph,
      ip: FFaker::Internet.ip_v4_address
    }
  end

  describe 'validations' do
    it 'is valid with all required attributes' do
      post = described_class.new(valid_attributes)
      expect(post).to be_valid
    end

    context 'when required attributes are missing' do
      it 'is invalid without a title' do
        post = described_class.new(valid_attributes.merge(title: nil))
        expect(post).not_to be_valid
        expect(post.errors[:title]).to include("can't be blank")
      end

      it 'is invalid without a body' do
        post = described_class.new(valid_attributes.merge(body: nil))
        expect(post).not_to be_valid
        expect(post.errors[:body]).to include("can't be blank")
      end

      it 'is invalid without an IP address' do
        post = described_class.new(valid_attributes.merge(ip: nil))
        expect(post).not_to be_valid
        expect(post.errors[:ip]).to include("can't be blank")
      end

      it 'is invalid with an empty title string' do
        post = described_class.new(valid_attributes.merge(title: ''))
        expect(post).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'requires a user' do
      post = described_class.new(valid_attributes.merge(user: nil))
      expect(post).not_to be_valid
      expect(post.errors[:user]).to include("must exist")
    end
  end

  describe 'database constraints' do
    context 'not null constraints' do
      it 'raises error when title is null at DB level' do
        post = build(:post, title: nil)
        expect { post.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'raises error when body is null at DB level' do
        post = build(:post, body: nil)
        expect { post.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'raises error when ip is null at DB level' do
        post = build(:post, ip: nil)
        expect { post.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end
  end

  describe '.top_rated' do
    it 'returns the N posts with the highest average rating' do
      low = create(:post, title: 'Low')
      mid = create(:post, title: 'Mid')
      high = create(:post, title: 'High')

      create_list(:rating, 3, post: low, value: 2)
      create_list(:rating, 3, post: mid, value: 3)
      create_list(:rating, 3, post: high, value: 5)

      result = Post.top_rated(2)

      expect(result.map(&:title)).to eq([ 'High', 'Mid' ])
    end
  end

  describe '.grouped_ips_with_logins' do
    it 'returns IPs with unique logins of authors' do
      user1 = create(:user, login: 'igor')
      user2 = create(:user, login: 'bruno')
      user3 = create(:user, login: 'larissa')

      create(:post, user: user1, ip: '1.1.1.1')
      create(:post, user: user2, ip: '1.1.1.1')
      create(:post, user: user3, ip: '2.2.2.2')
      create(:post, user: user1, ip: '1.1.1.1')

      result = Post.grouped_ips_with_logins(5)

      expect(result).to contain_exactly(
        { ip: '1.1.1.1', logins: match_array([ 'igor', 'bruno' ]) },
        { ip: '2.2.2.2', logins: [ 'larissa' ] }
      )
    end
  end

  describe '#average_rating' do
    let(:post) { create(:post) }

    context 'when post has no ratings' do
      it 'returns 0' do
        expect(post.average_rating).to eq(0)
      end
    end

    context 'when post has one rating' do
      it 'returns that rating value' do
        create(:rating, post: post, value: 4)
        expect(post.average_rating).to eq(4.0)
      end
    end

    context 'when post has multiple ratings' do
      it 'returns the correct average' do
        create(:rating, post: post, value: 2)
        create(:rating, post: post, value: 4)
        expect(post.average_rating).to eq(3.0)
      end
    end

    context 'when ratings include decimal values' do
      it 'returns the precise average' do
        expect {
          create(:rating, post: post, value: 4.5)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when ratings are updated' do
      it 'recalculates the average' do
        rating = create(:rating, post: post, value: 1)
        expect(post.average_rating).to eq(1.0)

        rating.update(value: 5)
        expect(post.reload.average_rating).to eq(5.0)
      end
    end
  end
end
