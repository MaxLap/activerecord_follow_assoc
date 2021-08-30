require_relative "support/spec_helper"

# Specs testing conditions on the associations

describe "follow_assoc" do
  it "follows has_many with conditions" do
    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1', spam: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', spam: 1)
    p3 = Post.create!(title: 'p3')
    p3.comments.create!(content: 'c3.1')

    Post.follow_assoc(:spam_comments).to_a.sort_by(&:id).should == [c1_1, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:spam_comments).to_a.sort_by(&:id).should == [c2_2]

    Post.follow_assoc(:spam_comments_s).to_a.sort_by(&:id).should == [c1_1, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:spam_comments_s).to_a.sort_by(&:id).should == [c2_2]
    Post.follow_assoc(:spam_comments_a).to_a.sort_by(&:id).should == [c1_1, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:spam_comments_a).to_a.sort_by(&:id).should == [c2_2]
  end

  it "follows belongs_to with conditions" do
    p1 = Post.create!(title: 'p1', published: 1)
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    p3 = Post.create!(title: 'p3', published: 1)
    p3.comments.create!(content: 'c3.1')
    p4 = Post.create!(title: 'p4', published: 1)
    p5 = Post.create!(title: 'p5')

    Comment.follow_assoc(:published_post).to_a.sort_by(&:id).should == [p1, p3]
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:published_post).to_a.sort_by(&:id).should == [p1]
    Comment.follow_assoc(:published_post_s).to_a.sort_by(&:id).should == [p1, p3]
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:published_post_s).to_a.sort_by(&:id).should == [p1]
    Comment.follow_assoc(:published_post_a).to_a.sort_by(&:id).should == [p1, p3]
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:published_post_a).to_a.sort_by(&:id).should == [p1]
  end

  it "follows has_many with conditions twice" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    p1 = Post.create!(title: 'p1', section: s1, published: 1)
    c1_1 = p1.comments.create!(content: 'c1.1', spam: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2', section: s2)
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', spam: 1)
    p3 = Post.create!(title: 'p3', section: s1, published: 1)
    p3.comments.create!(content: 'c3.1')

    Section.follow_assoc(:published_posts, :spam_comments).to_a.sort_by(&:id).should == [c1_1]
    Section.where(name: 's2').follow_assoc(:published_posts, :spam_comments).to_a.sort_by(&:id).should == []
    Section.follow_assoc(:published_posts_s, :spam_comments_s).to_a.sort_by(&:id).should == [c1_1]
    Section.where(name: 's2').follow_assoc(:published_posts, :spam_comments_s).to_a.sort_by(&:id).should == []
    Section.follow_assoc(:published_posts_a, :spam_comments_a).to_a.sort_by(&:id).should == [c1_1]
    Section.where(name: 's2').follow_assoc(:published_posts_a, :spam_comments_a).to_a.sort_by(&:id).should == []
  end

  it "follows belongs_to with conditions twice" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2', public: 1)
    p1 = Post.create!(title: 'p1', section: s1, published: 1)
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2', section: s1)
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    p3 = Post.create!(title: 'p3', section: s2, published: 1)
    p3.comments.create!(content: 'c3.1')

    Comment.follow_assoc(:published_post, :public_section).to_a.sort_by(&:id).should == [s2]
    Comment.where(content: 'c1.1').follow_assoc(:published_post, :public_section).to_a.sort_by(&:id).should == []
    Comment.where(content: 'c3.1').follow_assoc(:published_post, :public_section).to_a.sort_by(&:id).should == [s2]
    Comment.follow_assoc(:published_post_s, :public_section_s).to_a.sort_by(&:id).should == [s2]
    Comment.where(content: 'c1.1').follow_assoc(:published_post_s, :public_section_s).to_a.sort_by(&:id).should == []
    Comment.where(content: 'c3.1').follow_assoc(:published_post_s, :public_section_s).to_a.sort_by(&:id).should == [s2]
    Comment.follow_assoc(:published_post_a, :public_section_a).to_a.sort_by(&:id).should == [s2]
    Comment.where(content: 'c1.1').follow_assoc(:published_post_a, :public_section_a).to_a.sort_by(&:id).should == []
    Comment.where(content: 'c3.1').follow_assoc(:published_post_a, :public_section_a).to_a.sort_by(&:id).should == [s2]
  end

  it "follows has_many through: has_many_with_conditions, source: has_many_with_conditions" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    p1 = Post.create!(title: 'p1', section: s1, published: 1)
    c1_1 = p1.comments.create!(content: 'c1.1', spam: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2', section: s2)
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', spam: 1)
    p3 = Post.create!(title: 'p3', section: s1, published: 1)
    p3.comments.create!(content: 'c3.1')

    Section.follow_assoc(:published_spam_comments).to_a.sort_by(&:id).should == [c1_1]
    Section.follow_assoc(:published_spam_comments_s).to_a.sort_by(&:id).should == [c1_1]
    Section.follow_assoc(:published_spam_comments_a).to_a.sort_by(&:id).should == [c1_1]
  end

  it "follows has_many_and_belongs_to_many with conditions" do
    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2')
    p3 = Post.create!(title: 'p3')

    t1 = Tag.create(name: 't1')
    t2 = Tag.create(name: 't2', internal: 1)
    t3 = Tag.create(name: 't3', internal: 1)
    t4 = Tag.create(name: 't4', internal: 1)

    p1.tags << t1
    p1.tags << t2
    p2.tags << t1
    p3.tags << t3

    Post.where(title: %w(p1 p3)).follow_assoc(:internal_tags).to_a.sort_by(&:id).should == [t2, t3]
    Post.where(title: 'p2').follow_assoc(:internal_tags).to_a.should == []
    Post.where(title: %w(p1 p3)).follow_assoc(:internal_tags_s).to_a.sort_by(&:id).should == [t2, t3]
    Post.where(title: 'p2').follow_assoc(:internal_tags_s).to_a.should == []
    Post.where(title: %w(p1 p3)).follow_assoc(:internal_tags_a).to_a.sort_by(&:id).should == [t2, t3]
    Post.where(title: 'p2').follow_assoc(:internal_tags_a).to_a.should == []
  end

  it "follows has_one with conditions" do
    skip if Test::SelectedDBHelper == Test::MySQL

    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1', spam: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    c1_3 = p1.comments.create!(content: 'c1.3', spam: 1)
    p2 = Post.create!(title: 'p2')
    c2_1 = p1.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', spam: 1)
    c2_3 = p1.comments.create!(content: 'c2.3')
    p3 = Post.create!(title: 'p3')
    p3.comments.create!(content: 'c3.1')

    Post.follow_assoc(:latest_spam_comment).to_a.sort_by(&:id).should == [c1_3, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:latest_spam_comment).to_a.sort_by(&:id).should == [c2_2]
    Post.follow_assoc(:latest_spam_comment_s).to_a.sort_by(&:id).should == [c1_3, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:latest_spam_comment_s).to_a.sort_by(&:id).should == [c2_2]
    Post.follow_assoc(:latest_spam_comment_a).to_a.sort_by(&:id).should == [c1_3, c2_2]
    Post.where(title: %w(p2 p3)).follow_assoc(:latest_spam_comment_a).to_a.sort_by(&:id).should == [c2_2]
  end
end
