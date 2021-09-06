require_relative "support/spec_helper"

# Specs testing conditions on the associations

describe "follow_assoc" do
  it "follows has_many with limit on the assoc" do
    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    c2_3 = p2.comments.create!(content: 'c2.3')
    c2_4 = p2.comments.create!(content: 'c2.4')
    c2_5 = p2.comments.create!(content: 'c2.5')
    p3 = Post.create!(title: 'p3')
    c3_1 = p3.comments.create!(content: 'c3.1')

    Post.follow_assoc(:earliest_3_comments).to_a.sort_by(&:id).should == [c1_1, c1_2, c2_1, c2_2, c2_3, c3_1]
    Post.where(title: %w(p2 p3)).follow_assoc(:earliest_3_comments).to_a.sort_by(&:id).should == [c2_1, c2_2, c2_3, c3_1]

    Post.follow_assoc(:latest_3_comments).to_a.sort_by(&:id).should == [c1_1, c1_2, c2_3, c2_4, c2_5, c3_1]
    Post.where(title: %w(p2 p3)).follow_assoc(:latest_3_comments).to_a.sort_by(&:id).should == [c2_3, c2_4, c2_5, c3_1]
  end

  it "follows has_many with limit on the assoc, respecting ignore_limit: true" do
    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    c2_3 = p2.comments.create!(content: 'c2.3')
    c2_4 = p2.comments.create!(content: 'c2.4')
    c2_5 = p2.comments.create!(content: 'c2.5')
    p3 = Post.create!(title: 'p3')
    c3_1 = p3.comments.create!(content: 'c3.1')

    Post.follow_assoc(:earliest_3_comments, ignore_limit: true).to_a.sort_by(&:id).should == [c1_1, c1_2, c2_1, c2_2, c2_3, c2_4, c2_5, c3_1]
    Post.where(title: %w(p2 p3)).follow_assoc(:earliest_3_comments, ignore_limit: true).to_a.sort_by(&:id).should == [c2_1, c2_2, c2_3, c2_4, c2_5, c3_1]

    Post.follow_assoc(:latest_3_comments, ignore_limit: true).to_a.sort_by(&:id).should == [c1_1, c1_2, c2_1, c2_2, c2_3, c2_4, c2_5, c3_1]
    Post.where(title: %w(p2 p3)).follow_assoc(:latest_3_comments, ignore_limit: true).to_a.sort_by(&:id).should == [c2_1, c2_2, c2_3, c2_4, c2_5, c3_1]
  end
end
