# frozen_string_literal: true

# This contains the models and the code to create the table.
# This makes it simpler to see both the columns dans the associations for making tests.

class Comment < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :comments do |t|
      t.integer :post_id
      t.integer :parent_comment_id
      t.string :content
      t.integer :spam, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
      t.integer :default_scope_hidden_comment, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
    end
    add_index :comments, :content, unique: true # Helps avoid mistakes in a test's code
  end

  belongs_to :post
  belongs_to :published_post, -> { where(published: 1) }, class_name: 'Post', foreign_key: :post_id
  belongs_to :published_post_s, -> { where("published = 1") }, class_name: 'Post', foreign_key: :post_id
  belongs_to :published_post_a, -> { where("published = ?", 1) }, class_name: 'Post', foreign_key: :post_id

  belongs_to :parent_comment, optional: true, class_name: 'Comment'
  has_many :child_comments, foreign_key: :parent_comment_id, class_name: 'Comment'
  has_one :latest_child_comment, -> { order('id desc') }, class_name: 'Comment', foreign_key: :parent_comment_id

  # The presence of the obj argument makes this not work with follow_assoc (because this makes the association
  # instance dependent)
  # Only used to ensure the error message is clear
  belongs_to :instance_dependent_post, -> (obj) { "Never executed, tests fail before reaching this" }, class_name: 'Post'

  has_one :section, through: :post

  default_scope -> { where(default_scope_hidden_comment: 0) }
end

class Post < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :posts do |t|
      t.integer :section_id
      t.string :title
      t.integer :author_id, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
      t.integer :published, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
      t.integer :default_scope_hidden_post, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
    end
    add_index :posts, :title, unique: true # Helps avoid mistakes in a test's code
  end

  has_many :comments
  has_many :spam_comments, -> { where(spam: 1) }, class_name: 'Comment'
  has_many :spam_comments_s, -> { where("spam = 1") }, class_name: 'Comment'
  has_many :spam_comments_a, -> { where("spam = ?", 1) }, class_name: 'Comment'

  # Not having order should only happen when there is actually only one record. Otherwise, it's a fun souce of bugs...
  has_one :one_comment_without_order, class_name: 'Comment'
  has_one :latest_comment, -> { order('id desc') }, class_name: 'Comment'
  has_many :latest_3_comments, -> { order('id desc').limit(3) }, class_name: 'Comment'
  has_one :earliest_comment, -> { order('id asc') }, class_name: 'Comment'
  has_many :earliest_3_comments, -> { order('id asc').limit(3) }, class_name: 'Comment'
  has_one :latest_spam_comment, -> { where(spam: 1).order('id desc') }, class_name: 'Comment'
  has_one :latest_spam_comment_s, -> { where("spam = 1").order('id desc') }, class_name: 'Comment'
  has_one :latest_spam_comment_a, -> { where("spam = ?", 1).order('id desc') }, class_name: 'Comment'

  belongs_to :section
  belongs_to :public_section, -> { where(public: 1) }, class_name: 'Section', foreign_key: 'section_id'
  belongs_to :public_section_s, -> { where("public = 1") }, class_name: 'Section', foreign_key: 'section_id'
  belongs_to :public_section_a, -> { where("public = ?", 1) }, class_name: 'Section', foreign_key: 'section_id'
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :internal_tags, -> { where(internal: 1) }, class_name: 'Tag'
  has_and_belongs_to_many :internal_tags_s, -> { where("internal = 1") }, class_name: 'Tag'
  has_and_belongs_to_many :internal_tags_a, -> { where("internal = ?", 1) }, class_name: 'Tag'

  has_many :referring_PolyBelongsTo, class_name: 'PolyBelongsTo', as: :referred
  has_one :one_referring_PolyBelongsTo, -> { order('name ASC') }, class_name: 'PolyBelongsTo', as: :referred

  belongs_to :author, class_name: 'User'
  has_many :users_that_favorited_my_section, class_name: 'User', through: :section, source: :favoriting_users

  # The presence of the obj argument makes these not work with follow_assoc (because this makes the association
  # instance dependent)
  # Only used to ensure the error message is clear
  has_many :instance_dependent_comments, -> (obj) { "Never executed, tests fail before reaching this" }, class_name: 'Comment'
  has_one :instance_dependent_one_comment, -> (obj) { "Never executed, tests fail before reaching this" }, class_name: 'Comment'
  has_and_belongs_to_many :instance_dependent_tags, -> (obj) { "Never executed, tests fail before reaching this" }, class_name: 'Tag'

  default_scope -> { where(default_scope_hidden_post: 0) }
end

class Section < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :sections do |t|
      t.string :name
      t.integer :public
      t.integer :default_scope_hidden_section, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
    end
    add_index :sections, :name, unique: true # Helps avoid mistakes in a test's code
  end

  has_many :posts
  has_many :comments, through: :posts

  has_many :published_posts, -> { where(published: 1) }, class_name: 'Post'
  has_many :published_posts_s, -> { where("published = 1") }, class_name: 'Post'
  has_many :published_posts_a, -> { where("published = ?", 1) }, class_name: 'Post'
  has_many :published_spam_comments, through: :published_posts, source: :spam_comments
  has_many :published_spam_comments_s, through: :published_posts_s, source: :spam_comments_s
  has_many :published_spam_comments_a, through: :published_posts_a, source: :spam_comments_a

  has_many :favoriting_users, class_name: 'User', foreign_key: 'favorite_section_id'
  has_one :latest_favoriting_user, -> { order("id desc")}, class_name: 'User', foreign_key: 'favorite_section_id'

  default_scope -> { where(default_scope_hidden_section: 0) }
end

class Tag < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :tags do |t|
      t.string :name
      t.integer :internal, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
      t.integer :default_scope_hidden_tag, null: false, default: 0 # basically a boolean... but had some issues with sqlite in
    end
    add_index :tags, :name, unique: true # Helps avoid mistakes in a test's code
  end

  has_and_belongs_to_many :posts

  default_scope -> { where(default_scope_hidden_tag: 0) }
end

class RecursiveHasAndBelongsToMany < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :recursive_has_and_belongs_to_manies do |t|
      t.string :name
    end
    add_index :recursive_has_and_belongs_to_manies, :name, unique: true # Helps avoid mistakes in a test's code
  end

  has_and_belongs_to_many :recursion_as_first, class_name: 'RecursiveHasAndBelongsToMany', foreign_key: :first_id, association_foreign_key: :second_id, join_table: :recursive_has_and_belongs_to_many_join
  has_and_belongs_to_many :recursion_as_second, class_name: 'RecursiveHasAndBelongsToMany', foreign_key: :second_id, association_foreign_key: :first_id, join_table: :recursive_has_and_belongs_to_many_join
end

class PolyBelongsTo < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :poly_belongs_tos do |t|
      t.string :name
      t.string :referred_type
      t.integer :referred_id
      t.integer :user_id
    end
    add_index :poly_belongs_tos, :name, unique: true # Helps avoid mistakes in a test's code
  end

  belongs_to :referred, polymorphic: true
  belongs_to :user
  has_many :referring_PolyBelongsTo, class_name: 'PolyBelongsTo', as: :referred
end

class User < ActiveRecord::Base
  CREATE_TABLE_BLOCK = proc do
    create_table :users do |t|
      t.string :name
      t.string :type

      t.integer :favorite_section_id
    end
    add_index :users, :name, unique: true # Helps avoid mistakes in a test's code
  end

  belongs_to :favorite_section, class_name: 'Section'
  has_many :posts_in_favorite_section, class_name: 'Post', through: :favorite_section, source: :posts
  has_many :poly_belongs_tos
  has_many :posts_through_PolyBelongsTo, through: :poly_belongs_tos, source: :referred, source_type: "Post"
end

class SimpleUser < User
end

class CoolUser < User
end
