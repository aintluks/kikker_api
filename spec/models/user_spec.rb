require 'rails_helper'

# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:valid_user) { build(:user) }

    it 'is valid with a login' do
      expect(valid_user).to be_valid
    end

    it 'is invalid without a login' do
      user = build(:user, login: nil)
      expect(user).not_to be_valid
      expect(user.errors[:login]).to include("can't be blank")
    end

    it 'is invalid with an empty login' do
      user = build(:user, login: '')
      expect(user).not_to be_valid
      expect(user.errors[:login]).to include("can't be blank")
    end
  end

  describe 'database constraints' do
    it 'raises ActiveRecord::NotNullViolation when saving without login' do
      user = build(:user, login: nil)
      expect { user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
