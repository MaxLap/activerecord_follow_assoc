require_relative "support/spec_helper"

# When an association has a scope that takes an object, it's not possible to `joins` or eager load it,
# because it needs to have an instance to do its job.
# Make sure we provide a correct error message in those cases, like Rails

describe "follow_assoc" do
  it "refuses instance dependent has_many" do
    skip if ActiveRecord.gem_version < Gem::Version.new("5.0")
    expect { Post.follow_assoc(:instance_dependent_comments) }.to raise_error(/instance dependent/)
  end

  it "refuses instance dependent belongs_to" do
    skip if ActiveRecord.gem_version < Gem::Version.new("5.0")
    expect { Comment.follow_assoc(:instance_dependent_post) }.to raise_error(/instance dependent/)
  end

  it "refuses instance dependent has_one" do
    skip if ActiveRecord.gem_version < Gem::Version.new("5.0")
    expect { Post.follow_assoc(:instance_dependent_one_comment) }.to raise_error(/instance dependent/)
  end

  it "refuses instance dependent has_and_belongs_to_many" do
    skip if ActiveRecord.gem_version < Gem::Version.new("5.0")
    expect { Post.follow_assoc(:instance_dependent_tags) }.to raise_error(/instance dependent/)
  end
end
