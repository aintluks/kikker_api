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
end
