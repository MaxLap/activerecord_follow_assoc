require_relative "support/spec_helper"

# Specs testing recursive associations, such as Comment having child comments by adding a parent_comment_id to it.

describe "follow_assoc" do
  it "follows a recursive has_many" do
    c1 = Comment.create!(content: 'c1')
    c2 = Comment.create!(content: 'c2')
    c2_1 = c2.child_comments.create!(content: 'c2.1')
    c2_1_1 = c2_1.child_comments.create!(content: 'c2.1.1')
    c2_2 = c2.child_comments.create!(content: 'c2.2')
    c3 = Comment.create!(content: 'c3')
    c3_1 = c3.child_comments.create!(content: 'c3.1')
    c4 = Comment.create!(content: 'c4')

    Comment.follow_assoc(:child_comments).to_a.sort_by(&:id).should == [c2_1, c2_1_1, c2_2, c3_1]
    Comment.where(parent_comment_id: nil).follow_assoc(:child_comments).to_a.sort_by(&:id).should == [c2_1, c2_2, c3_1]
  end

  it "follows a recursive belongs_to" do
    c1 = Comment.create!(content: 'c1')
    c2 = Comment.create!(content: 'c2')
    c2_1 = c2.child_comments.create!(content: 'c2.1')
    c2_1_1 = c2_1.child_comments.create!(content: 'c2.1.1')
    c2_2 = c2.child_comments.create!(content: 'c2.2')
    c3 = Comment.create!(content: 'c3')
    c3_1 = c3.child_comments.create!(content: 'c3.1')
    c4 = Comment.create!(content: 'c4')

    Comment.follow_assoc(:parent_comment).to_a.sort_by(&:id).should == [c2, c2_1, c3]
    Comment.where(parent_comment_id: nil).follow_assoc(:parent_comment).to_a.sort_by(&:id).should == []
  end

  it "follows a recursive has_one" do
    # I gave up on those. SQL makes it hard to express this, and I end up needed
    # extra steps which I fear will affect the final performance of the query...
    # So yeah, makes it feel like a probable waste of my time.
    expect { Comment.follow_assoc(:latest_child_comment) }.to raise_error(/is a recursive has_one/)
  end

  it "follows a recursive has_and_belongs_to_many" do
    r1 = RecursiveHasAndBelongsToMany.create!(name: 'r1')
    r2 = RecursiveHasAndBelongsToMany.create!(name: 'r2')
    r1_1 = r1.recursion_as_first.create!(name: 'r1.1')
    r1_1_1 = r1_1.recursion_as_first.create!(name: 'r1.1.1')
    r1_2 = r1.recursion_as_first.create!(name: 'r1.2')

    RecursiveHasAndBelongsToMany.follow_assoc(:recursion_as_first).to_a.sort_by(&:id).should == [r1_1, r1_1_1, r1_2]
    RecursiveHasAndBelongsToMany.follow_assoc(:recursion_as_second).to_a.sort_by(&:id).should == [r1, r1_1]
  end
end
