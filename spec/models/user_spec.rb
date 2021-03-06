require "rails_helper"

RSpec.describe User do
  context "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_presence_of(:username) }

    context "uniqueness" do
      before { create(:user) }

      it { is_expected.to validate_uniqueness_of(:email) }
      it { is_expected.to validate_uniqueness_of(:username) }
    end
  end

  context "#users_to_follow" do
    it "returns the first 3 users, excluding the current user" do
      user = create(:user)
      recommended = create_list(:user, 3)
      _not_recommended = create(:user)

      result = user.users_to_follow

      expect(result).to eq recommended
    end
  end

  context "#recommend" do
    it "adds a television show to a user's recommendations" do
      television_show = create(:television_show)
      user = create(:user)

      user.recommend(television_show)

      user.reload
      expect(user.television_shows).to eq [television_show]
    end

    context "when the user already recommended it" do
      it "returns falsy" do
        television_show = create(:television_show)
        user = create(:user)

        user.recommend(television_show)
        result = user.recommend(television_show)

        expect(result).to be_falsy
      end
    end
  end

  context "#follow" do
    it "follows a user" do
      follower = create(:user)
      followed = create(:user)

      follower.follow(followed)

      follower.reload
      expect(follower.following).to eq [followed]
    end
  end

  context "#unfollow" do
    it "unfollows a user" do
      follower = create(:user)
      followed = create(:user)

      follower.follow(followed)
      follower.unfollow(followed)

      follower.reload
      expect(follower.following).to be_empty
    end
  end

  context "#following" do
    it "returns true if a user is following that user" do
      follower = create(:user)
      followed = create(:user)

      follower.follow(followed)

      expect(follower).to be_following followed
    end

    it "returns false if a user is not following that user" do
      user = create(:user)
      stranger = create(:user)

      expect(user).not_to be_following stranger
    end
  end

  context "#with_following" do
    it "returns the user and the users they are following" do
      user = create(:user)
      following = create(:user)
      user.follow(following)

      result = user.with_following

      expect(result).to match_array [user, following]
    end

    it "does not return unfollowed users" do
      user = create(:user)
      not_following = create(:user)

      result = user.with_following

      expect(result).not_to include not_following
    end
  end
end
