require_relative "support/spec_helper"

# Specs testing polymorphic associations
# Right now, there is no support for them, but it's likely something I would want to add at one point.
describe "follow_assoc" do
  it "refuses a polymorphic belongs_to without poly_belongs_to option" do
    expect { PolyBelongsTo.follow_assoc(:referred) }.to raise_error(ActiveRecordFollowAssoc::PolymorphicBelongsToWithoutClasses)
  end

  it "follow a polymorphic belongs_to with :poly_belongs_to option" do
    p1 = Post.create!(title: 'p1')
    c1_1 = p1.comments.create!(content: 'c1.1')
    c1_2 = p1.comments.create!(content: 'c1.2')
    p2 = Post.create!(title: 'p2')
    c2_1 = p2.comments.create!(content: 'c2.1')
    c2_2 = p2.comments.create!(content: 'c2.2')
    p3 = Post.create!(title: 'p3')
    p3.comments.create!(content: 'c3.1')

    pb1 = PolyBelongsTo.create!(name: 'pb1', referred: p1)
    pb2 = PolyBelongsTo.create!(name: 'pb2', referred: c2_1)
    pb3 = PolyBelongsTo.create!(name: 'pb3', referred: p2)

    PolyBelongsTo.follow_assoc(:referred, poly_belongs_to: Post).to_a.sort_by(&:id).should == [p1, p2]
    PolyBelongsTo.follow_assoc(:referred, poly_belongs_to: Comment).to_a.sort_by(&:id).should == [c2_1]
  end

  it "follow a recursive polymorphic belongs_to with :poly_belongs_to option" do
    p1 = Post.create!(title: 'p1')
    pb1 = PolyBelongsTo.create!(name: 'pb1', referred: p1)
    pb2 = PolyBelongsTo.create!(name: 'pb2', referred: pb1)

    PolyBelongsTo.follow_assoc(:referred, poly_belongs_to: PolyBelongsTo).to_a.sort_by(&:id).should == [pb1]
    end

  it "follow a has_many with :as option (polymorphic)" do
    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2')
    pb1 = PolyBelongsTo.create!(name: 'pb1', referred: p1)
    pb2 = PolyBelongsTo.create!(name: 'pb2', referred: pb1)

    Post.follow_assoc(:referring_PolyBelongsTo).to_a.sort_by(&:id).should == [pb1]
  end

  it "follow a recursive has_many with :as option (polymorphic)" do
    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2')
    pb1 = PolyBelongsTo.create!(name: 'pb1', referred: p1)
    pb2 = PolyBelongsTo.create!(name: 'pb2', referred: pb1)

    PolyBelongsTo.follow_assoc(:referring_PolyBelongsTo).to_a.sort_by(&:id).should == [pb2]
  end

  it "follow a has_one with :as option (polymorphic)" do
    skip if Test::SelectedDBHelper == Test::MySQL

    p1 = Post.create!(title: 'p1')
    p2 = Post.create!(title: 'p2')
    pb1 = PolyBelongsTo.create!(name: 'pb1', referred: p1)
    pb2 = PolyBelongsTo.create!(name: 'pb2', referred: pb1)
    pb3 = PolyBelongsTo.create!(name: 'pb3', referred: p1)

    Post.follow_assoc(:one_referring_PolyBelongsTo).to_a.sort_by(&:id).should == [pb1]

    pb0 = PolyBelongsTo.create!(name: 'pb0', referred: p1)
    Post.follow_assoc(:one_referring_PolyBelongsTo).to_a.sort_by(&:id).should == [pb0]
  end
end
