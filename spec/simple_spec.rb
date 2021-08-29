require_relative "support/spec_helper"

# Very simple specs just showing very basic usage in simple cases
# No conditions on the associations

describe "follow_assoc" do
  before do
    @s1 = Section.create!(name: 's1')
    @s2 = Section.create!(name: 's2')
    @p1 = Post.create!(title: 'p1', section: @s1)
    @c1_1 = @p1.comments.create!(content: 'c1.1')
    @p2 = Post.create!(title: 'p2', section: @s1)
    @c2_1 = @p2.comments.create!(content: 'c2.1')
    @c2_2 = @p2.comments.create!(content: 'c2.2')
    @p3 = Post.create!(title: 'p3', section: @s2)
    @p3.comments.create!(content: 'c3.1')
  end

  it "follows has_many" do
    Post.where(title: 'p1').follow_assoc(:comments).to_a.should == [@c1_1]
    Post.where(title: %w(p1 p2)).follow_assoc(:comments).to_a.sort_by(&:id).should == [@c1_1, @c2_1, @c2_2]
  end

  it "follows belongs_to" do
    Comment.where(content: 'c1.1').follow_assoc(:post).to_a.should == [@p1]
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:post).to_a.sort_by(&:id).should == [@p1, @p2]
  end

  it "follows has_many twice" do
    Section.where(name: 's1').follow_assoc(:posts, :comments).to_a.sort_by(&:id).should == [@c1_1, @c2_1, @c2_2]
  end

  it "follows belongs_to twice" do
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:post, :section).to_a.should == [@s1]
  end

  it "follows has_many through: has_many" do
    Section.where(name: 's1').follow_assoc(:comments).to_a.should == [@c1_1, @c2_1, @c2_2]
  end

  it "follows has_many_and_belongs_to_many" do
    @t1 = Tag.create(name: 't1')
    @t2 = Tag.create(name: 't2')
    @t3 = Tag.create(name: 't3')

    @p1.tags << @t1
    @p1.tags << @t2
    @p2.tags << @t1
    @p3.tags << @t3

    Tag.where(name: 't1').follow_assoc(:posts).to_a.sort_by(&:id).should == [@p1, @p2]
    Tag.where(name: %w(t2 t3)).follow_assoc(:posts).to_a.sort_by(&:id).should == [@p1, @p3]

    Post.where(title: %w(p1 p3)).follow_assoc(:tags).to_a.sort_by(&:id).should == [@t1, @t2, @t3]
    Post.where(title: 'p2').follow_assoc(:tags).to_a.should == [@t1]
  end

  it "follows has_one" do
    Post.where(title: 'p2').follow_assoc(:latest_comment).to_a.sort_by(&:id).should == [@c2_2]
    Post.where(title: 'p2').follow_assoc(:earliest_comment).to_a.sort_by(&:id).should == [@c2_1]
    Post.where(title: %w(p1 p2)).follow_assoc(:latest_comment).to_a.sort_by(&:id).should == [@c1_1, @c2_2]

    # Testing the case where the has_one has no orde@.. Should normally only happen if there is
    # actually only one record that matches.
    Post.where(title: 'p2').follow_assoc(:one_comment_without_order).to_a.should be_one_of([[@c2_1], [@c2_2]])
  end
end
