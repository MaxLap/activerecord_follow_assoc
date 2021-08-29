require_relative "support/spec_helper"

# Specs testing STI models

describe "follow_assoc" do
  it "follows a STI has_many" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    s3 = Section.create!(name: 's3')
    u1 = User.create!(name: 'u1', favorite_section: s2)
    u2 = User.create!(name: 'u2')
    u3 = User.create!(name: 'u3', favorite_section: s3)
    u4 = User.create!(name: 'u4', favorite_section: s3)

    Section.follow_assoc(:favoriting_users).to_a.sort_by(&:id).should == [u1, u3, u4]
    Section.where(name: 's3').follow_assoc(:favoriting_users).to_a.sort_by(&:id).should == [u3, u4]
  end

  it "follows a STI has_one" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    s3 = Section.create!(name: 's3')
    u1 = User.create!(name: 'u1', favorite_section: s2)
    u2 = User.create!(name: 'u2')
    u3 = User.create!(name: 'u3', favorite_section: s3)
    u4 = User.create!(name: 'u4', favorite_section: s3)

    Section.follow_assoc(:latest_favoriting_user).to_a.sort_by(&:id).should == [u1, u4]
    Section.where(name: 's3').follow_assoc(:latest_favoriting_user).to_a.sort_by(&:id).should == [u4]
  end


  it "follows a STI belongs_to" do
    u1 = User.create!(name: 'u1')
    u2 = User.create!(name: 'u2')
    u3 = User.create!(name: 'u3')
    u4 = User.create!(name: 'u4')
    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2', author: u2)
    p3 = Post.create!(title: 'p3', author: u3)
    p4 = Post.create!(title: 'p4', author: u2)

    Post.follow_assoc(:author).to_a.sort_by(&:id).should == [u2, u3]
    Post.where(title: %w(p1 p2)).follow_assoc(:author).to_a.sort_by(&:id).should == [u2]
  end

  it "follows a has_many through: STI" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    s3 = Section.create!(name: 's3')
    p1 = s1.posts.create!(title: 'p1')
    p2 = s2.posts.create!(title: 'p2')
    p3 = s3.posts.create!(title: 'p3')

    u1 = User.create!(name: 'u1', favorite_section: s2)
    u2 = User.create!(name: 'u2')
    u3 = User.create!(name: 'u3', favorite_section: s3)
    u4 = User.create!(name: 'u4', favorite_section: s3)

    User.follow_assoc(:posts_in_favorite_section).to_a.sort_by(&:id).should == [p2, p3]
    User.where(name: %w(u1 u2)).follow_assoc(:posts_in_favorite_section).to_a.sort_by(&:id).should == [p2]
  end

  it "follows a has_many :through with STI :source" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    s3 = Section.create!(name: 's3')
    p1 = s1.posts.create!(title: 'p1')
    p2 = s2.posts.create!(title: 'p2')
    p3 = s3.posts.create!(title: 'p3')

    u1 = User.create!(name: 'u1', favorite_section: s2)
    u2 = User.create!(name: 'u2')
    u3 = User.create!(name: 'u3', favorite_section: s3)
    u4 = User.create!(name: 'u4', favorite_section: s3)

    Post.follow_assoc(:users_that_favorited_my_section).to_a.sort_by(&:id).should == [u1, u3, u4]
    Post.where(title: %w(p1 p2)).follow_assoc(:users_that_favorited_my_section).to_a.sort_by(&:id).should == [u1]
  end

end
