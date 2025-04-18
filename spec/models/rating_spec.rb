require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(build(:rating)).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'requires a user' do
        rating = build(:rating, user: nil)
        expect(rating).not_to be_valid
        expect(rating.errors[:user]).to include('must exist')
      end

      it 'requires a post' do
        rating = build(:rating, post: nil)
        expect(rating).not_to be_valid
        expect(rating.errors[:post]).to include('must exist')
      end

      it 'requires a value' do
        rating = build(:rating, value: nil)
        expect(rating).not_to be_valid
        expect(rating.errors[:value]).to include("can't be blank")
      end

      it 'requires value >= 1' do
        rating = build(:rating, value: 0)
        expect(rating).not_to be_valid
        expect(rating.errors[:value]).to include('must be greater than or equal to 1')
      end

      it 'requires value <= 5' do
        rating = build(:rating, value: 6)
        expect(rating).not_to be_valid
        expect(rating.errors[:value]).to include('must be less than or equal to 5')
      end

      it 'requires integer value' do
        rating = build(:rating, value: 2.5)
        expect(rating).not_to be_valid
        expect(rating.errors[:value]).to include('must be an integer')
      end

      it 'prevents duplicate ratings by same user on same post' do
        rating = create(:rating)
        duplicate = build(:rating, user: rating.user, post: rating.post)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('can only rate a post once')
      end
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(Rating.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'belongs to a post' do
      expect(Rating.reflect_on_association(:post).macro).to eq(:belongs_to)
    end
  end

  describe 'database constraints' do
    context 'not null constraints' do
      it 'raises error when user_id is null' do
        expect { build(:rating, user: nil).save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'raises error when post_id is null' do
        expect { build(:rating, post: nil).save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'raises error when value is null' do
        expect { build(:rating, value: nil).save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    context 'value range constraint' do
      it 'rejects values below 1' do
        expect { build(:rating, value: 0).save(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it 'rejects values above 5' do
        expect { build(:rating, value: 6).save(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context 'unique constraint' do
      it 'prevents duplicate user-post pairs at database level' do
        rating = create(:rating)

        expect {
          Rating.new(
            user_id: rating.user_id,
            post_id: rating.post_id,
            value: 3
          ).save(validate: false)
        }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
