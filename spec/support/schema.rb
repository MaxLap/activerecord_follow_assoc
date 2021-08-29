# frozen_string_literal: true

ActiveRecord::Schema.verbose = false

# Every table is a step. In tests, you always go toward the bigger step.
# You can do it using a belongs_to, or has_one/has_many.
# Try to make most columns unique so that any wrong column used is obvious in an error message.

ActiveRecord::Schema.define do
  instance_exec(&Section::CREATE_TABLE_BLOCK)
  instance_exec(&Post::CREATE_TABLE_BLOCK)
  instance_exec(&Comment::CREATE_TABLE_BLOCK)
  instance_exec(&Tag::CREATE_TABLE_BLOCK)
  instance_exec(&RecursiveHasAndBelongsToMany::CREATE_TABLE_BLOCK)
  instance_exec(&PolyBelongsTo::CREATE_TABLE_BLOCK)
  instance_exec(&User::CREATE_TABLE_BLOCK)

  # Join tables for has_and_belongs_to_many
  create_table :posts_tags do |t|
    t.integer :post_id
    t.integer :tag_id
  end

  # Join table for has_and_belongs_to_many
  create_table :recursive_has_and_belongs_to_many_join do |t|
    t.integer :first_id
    t.integer :second_id
  end
end
