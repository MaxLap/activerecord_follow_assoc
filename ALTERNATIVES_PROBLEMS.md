This document contains examples and list of problems with the main ways of achieving results
similar to what `follow_assoc` does using only built-in ActiveRecord features.

Let's have two examples:
* you want to get all of the recent comments to the posts the current user made.
* you want to get all of the sections of the posts on which the current user made a comment

These are the the different strategies I know of:

## flat_map

```ruby
# recent comments on current_user's posts
# (Consider there exists a `recent?` method on comments)
current_user.posts.preload(:comments).flat_map(:comments).select { |c| c.recent? }
# sections in which current_user commented
current_user.comments.preload(post: :section).flat_map(&:post).flat_map(&:section)
```

You use the associations directly until you have an array from using a `has_many` association,
then you use `flat_map` for each associations.

Notes:
* `preload` does the same thing as `includes`: eager loading. I prefer to use `preload`
  and made a [blog post](https://maxlap.dev/blog/2021/02/15/you-should-avoid-includes-in-rails.html)
  about it.
* In the second example, because the associations are `belongs_to`, the `flat_map` could
  have just been `map`.

Problems:

* This returns an `Array`, so you can't use `where`, `order`, scopes you defined, etc.
  In the example, I had to do `.select { |c| c.recent? }` instead of using a scope `recent`.
* If you forget eager loading (`preload` / `includes`), you will have a case of N+1 query problem.
  This can slow down your page.
* Even without the N+1, this is wasteful:
  * It needs to load the posts to then be able to call `comments` on them, but none of the
    posts' data is used.
  * If you have 1000 comments, and only 2 are recent. You need to load all 1000 of them so
    that you can then filter them with Ruby (`select {...}`) to get the 2 comments you want.

## Nested queries

```ruby
# recent comments on current_user's posts
# (Consider there exists a scope `recent` on comments)
Comment.where(post_id: current_user.posts).recent
# sections in which current_user commented
Section.where(id: Post.where(id: current_user.comments.select(:post_id)).select(:section_id))
```

You nest the queries one inside of another. You gain:
* performance because you avoid doing multiple distinct queries and you only get the records you need.
* this returns a `Relation` (instead of an `Array`), so you can use `where`, `order`, scopes defined
  on the model.

Problems:
* Depending on if the association is a `belongs_to` or a `has_many`, you need choose between
  `where(post_id: ...)` and `where(id: ....select(:post_id))`.
* It's error prone. You can easily forget a `select(:post_id)`. It won't raise any error, will
  use the id, and you will get the wrong result. Hopefully you notice it.
* If the association is a `has_one`, then you need a much more complicated query to only receive a single
  associated record. Doing `where(post_id: ...)` treats the association as if it was a `has_many`.
* The intent (of goal) of the code is hidden. You are "following" one or more associations, but you don't name them!
  It must all be deduced from the name of the models and columns.
* If the association is changed, such as by adding a condition to it or changing the name of the column, those nested queries must all be changed.
* If the association has multiple steps (has_many :through), then you need multiple nested queries and
  it gets messy very fast.

## Adding an association

```ruby
class User < ApplicationRecord
  has_many :post
  
  # (an association for comments on current_user's posts)
  has_many :received_comments, through: :posts, class_name: 'Comment'
  
  # (or maybe even an association for recent comments on current_user's posts)
  # (Consider there exists a scope `recent` on comments)
  has_many :recent_received_comments, -> { recent }, through: :posts, class_name: 'Comment'
end

# recent comments on current_user's posts
current_user.received_comments.recent
# or
current_user.recent_received_comments

# ----------

class Comment < ApplicationRecord
  belongs_to :post
  has_one :section, through: :post
end

class User < ApplicationRecord
  has_many :comments
  # (an association for sections in which current_user commented)
  has_many :commented_in_sections, through: :comments, class_name: 'Comment', source: :section
end

# sections in which current_user commented
current_user.commented_in_sections
```

Problems:
* The deeper you need to go, the harder it is to name the association meaningfully.
* Do this too often and it becomes hard to find what you are looking for.
