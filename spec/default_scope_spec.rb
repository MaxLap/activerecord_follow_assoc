require_relative "support/spec_helper"

# Specs testing conditions on the associations

describe "follow_assoc" do
  it "follows has_many respecting default_scope" do
    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1', default_scope_hidden_comment: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', default_scope_hidden_comment: 1)
    p3 = Post.create!(title: 'p3', default_scope_hidden_post: 1)
    c3_1 = p3.comments.create!(content: 'c3.1')

    Post.follow_assoc(:comments).to_a.sort_by(&:id).should == [c1_2, c2_1]
    Post.where(title: %w(p2 p3)).follow_assoc(:comments).to_a.sort_by(&:id).should == [c2_1]
  end

  it "follows belongs_to respecting default_scope" do
    p1 = Post.create!(title: 'p1', default_scope_hidden_post: 1)
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    p3 = Post.create!(title: 'p3', default_scope_hidden_post: 1)
    p3.comments.create!(content: 'c3.1')
    p4 = Post.create!(title: 'p4', default_scope_hidden_post: 1)
    p5 = Post.create!(title: 'p5')
    p5.comments.create!(content: 'c5.1', default_scope_hidden_comment: 1)

    Comment.follow_assoc(:post).to_a.sort_by(&:id).should == [p2]
    Comment.where(content: %w(c1.1 c2.2)).follow_assoc(:post).to_a.sort_by(&:id).should == [p2]
  end

  it "follows has_many through respecting both default_scope" do
    s1 = Section.create!(name: 's1')
    s2 = Section.create!(name: 's2')
    s3 = Section.create!(name: 's3', default_scope_hidden_section: 1)

    p1 = Post.create!(title: 'p1', section: s1, default_scope_hidden_post: 1)
    c1_1 = p1.comments.create!(content: 'c1.1', default_scope_hidden_comment: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2', section: s2)
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', default_scope_hidden_comment: 1)
    p3 = Post.create!(title: 'p3', section: s1, default_scope_hidden_post: 1)
    p3.comments.create!(content: 'c3.1')
    p4 = Post.create!(title: 'p4', section: s3)
    p4.comments.create!(content: 'c4.1')

    Section.follow_assoc(:comments).to_a.sort_by(&:id).should == [c2_1]
  end

  it "follows has_belongs_to_many respecting default_scope" do
    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2')
    p3 = Post.create!(title: 'p3')
    p4 = Post.create!(title: 'p4', default_scope_hidden_post: 1)

    t1 = Tag.create(name: 't1')
    t2 = Tag.create(name: 't2', default_scope_hidden_tag: 1)
    t3 = Tag.create(name: 't3', default_scope_hidden_tag: 1)
    t4 = Tag.create(name: 't4')

    p1.tags << t1
    p1.tags << t2
    p2.tags << t1
    p3.tags << t3
    p4.tags << t4

    Post.where(title: %w(p1 p3 p4)).follow_assoc(:tags).to_a.sort_by(&:id).should == [t1]
    Post.where(title: 'p3').follow_assoc(:tags).to_a.should == []
  end

  it "follows has_one respecting default_scope" do
    skip if Test::SelectedDBHelper == Test::MySQL

    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1', default_scope_hidden_comment: 1)
    c1_2 = p1.comments.create!(content: 'c1.2')
    c1_3 = p1.comments.create!(content: 'c1.3', default_scope_hidden_comment: 1)
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2', default_scope_hidden_comment: 1)
    c2_3 = p2.comments.create!(content: 'c2.3')
    p3 = Post.create!(title: 'p3')
    c3_1 = p3.comments.create!(content: 'c3.1')
    p4 = Post.create!(title: 'p4', default_scope_hidden_post: 1)
    p4.comments.create!(content: 'c4.1')

    Post.follow_assoc(:latest_comment).to_a.sort_by(&:id).should == [c1_2, c2_3, c3_1]
    Post.where(title: %w(p1 p3)).follow_assoc(:latest_comment).to_a.sort_by(&:id).should == [c1_2, c3_1]
  end
end
