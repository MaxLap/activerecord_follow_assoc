This is an introduction to the
[activerecord_follow_assoc](https://github.com/MaxLap/activerecord_follow_assoc) gem.

Rails has a system to interact with your database called ActiveRecord. This gem
is an extension to it, making a specific use-case simpler.

Every once in a while, I need records that are pretty deep within my associations.
Let's have two examples:
* you want to get all of the recent comments to the posts the current user made.
* you want to get all of the sections of the posts on which the current user made a comment

How would you do it? Here are the ways I can think of (you don't need to understand them,
an overview follows):

```ruby
# recent comments on current_user's posts
# (flat_map way)
current_user.posts.preload(:comments).flat_map(:comments).select { |c| c.recent? }
# (nested query way)
Comment.where(post_id: current_user.posts).recent

# sections in which current_user commented
# (flat_map way)
current_user.comments.preload(post: :section).flat_map(&:post).flat_map(&:section)
# (nested query way)
Section.where(id: Post.where(id: current_user.comments.select(:post_id)).select(:section_id))
```

Notes:
* `preload` does the same thing as `includes`: eager loading. I prefer to use `preload`
  and made a [blog post](https://maxlap.dev/blog/2021/02/15/you-should-avoid-includes-in-rails.html)
  about it.
* In the second example, because the associations are `belongs_to`, the `flap_map` could
  have just been `map`.


`flat_map` way: You use the associations directly until you have an array from using a `has_many` association, then you use `flat_map` for each associations.

Nested query way: You nest the queries within one another, so you only have to do a single one. This usually has better performance since you need to load less records.

Adding associations way: A third way is possible, creating a custom association using `has_many` with the `:through` option. But adding many one-use association like that is noisy, impractical and annoying. There is an example in [ALTERNATIVES_PROBLEMS.md](ALTERNATIVES_PROBLEMS.md).

Each of those ways have problems or weaknesses:

* `flat_map` returns an `Array` instead of a `Relation`, so you can't use `where` or scopes on the returned
  data.
* The `flat_map` way is often inefficient
* The nested query way is error prone and hides the intent of the code.
* `belongs_to` and `has_many` need to be handled differently.
* Each way are verbose

That's just an overview. If you are curious, I made a [whole document](ALTERNATIVES_PROBLEMS.md)
with more problems and detailed explanations.

I had this feeling of "there is a tool missing here" for a long time. A way to do this that
didn't feel inefficient or cryptic.

[activerecord_follow_assoc](https://github.com/MaxLap/activerecord_follow_assoc) is my answer to
this feeling. With it, the above situations look like:

```ruby
# recent comments on current_user's posts
# (follow_assoc way)
my_comments = current_user.posts.follow_assoc(:comments).recent

# sections in which current_user commented
# (follow_assoc way)
my_sections = current_user.comments.follow_assoc(:post, :section)
```

It's almost too simple compared to the built-in ways. Readability-wise it's great, it actually says
what it does, step by step.

You can use it anywhere you could use `where`. You list the associations you want to
follow and then you can keep on using `where`, `order`, etc., but now you are working
on querying the records of the associations.

Other benefits:
* `follow_assoc` works the same way for `belongs_to` and `has_many`.  
* It handles a lot of edge-cases a lot more easily compared to the first 3 ways:
  * Recursive associations (ex: `Comments` having `sub_comments`)
  * `has_one` will only consider one associated record per record. Doing this
    with the nested query is quite complicated.
  * I can even handle polymorphic `belongs_to` in some cases.
* It does a single query, just like a regular chain of `where` would.

So, here is another example. Can you guess what it does?

```ruby
Post.published.follow_assoc(:author)
```

If you guessed "The authors that published posts" or "Published posts' authors", then it
means this introduction did it's job! Otherwise, if you want to provide feedback,
feel free to open an issue.

Here is the link to the gem: [activerecord_where_assoc](https://github.com/MaxLap/activerecord_where_assoc)
