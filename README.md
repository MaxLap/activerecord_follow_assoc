This gem is still a work in progress. It hasn't been released yet.

# ActiveRecord Follow Assoc

![Test supported versions](https://github.com/MaxLap/activerecord_follow_assoc/workflows/Test%20supported%20versions/badge.svg)

Easily follow associations in your ActiveRecord queries, so you can go from querying one model to querying
an association's model.

From this query: `my_posts = Post.where(published: true)`, you can do
`my_posts.follow_assoc(:comments)` to now query the comments of the published posts.

`follow_assoc` can follow all kinds of associations: `belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many`.

`has_one` will actually be treated as a has_one. So `my_posts.follow_assoc(:last_comment)` won't return every
comments of the posts in `my_posts`, only first one of each.

No query is executed by `follow_assoc`, so the `my_posts` query isn't loaded from the database. It's only when the
resulting relation is used that the query is executed.

## Why / when do you need this?

As applications grow, you can end up with quite complex data model and even more complex business rules. You may end up
needing to fetch records that are rather deep in your associations.

As a simple example, let's say you want the recent comments made in one of 3 sections of a blog.

```
# My section is the relation
# recent is a scope on comments.
my_sections.follow_assoc(:posts, :comments).recent
```

Doing this without follow_assoc can be verbose, error-prone and less efficient depending on the approach taken.

## The alternatives

Instead of using this gem, you can either:
* Use `map`/`flat_map`: `my_comments.includes(:post).map(&:post)` / `my_posts.includes(:comments).flat_map(&:comments)`
* Nest queries: `Comment.where(post_id: my_posts)` or `Section.where(id: my_posts.select(:section_id))`
* If you think of another way, feel free to open an issue.

With `flat_map`:
* You end up with an array instead of a relation, so you can't apply more scoping or other SQL-based tools.
* You need to do remember to do eager loading to avoid the infamous N+1 query problem
* If you need to filter the records, then you either:
  * do it in Ruby... so you loaded extra records
  * add an association with the condition... All those extra associations end up being noise.
* You need to load the posts to then be able to call `comments` on them. This is wasteful if you don't need the posts for anything else.

When nesting query:
* It's error prone. You can easily forget a `select(:section_id)`, and it will instead use the id.
* Using this approach for a `has_one` like `last_comment` without returning all the comments is hard.
* The intent of the code is hidden. You are following an association, but you never even name it.
* If the association is changed, such as by adding a condition to it or changing the name of the column, those nested queries must all be changed.
* If the association has multiple steps (has_many :through, has_and_belongs_to_many), then you need multiple nested queries.


Now consider a case where you want every users that commented to posts in some specific sections.
```ruby
my_sections = Section.where(...)

# flat_map:
my_sections.preload(:posts, :comments, :user).flat_map(&:posts).flat_map(&:comments).map(&:user)
# nesting query:
User.where(Comment.where(post_id: Post.where(section_id: my_sections)).select(:user_id))

# With the gem:
my_sections.follow_assoc(:posts, :comments, :user)
```

You could also add some `has_many :through` associations to make `flat_map` and `follow_assoc` shorter.

## Installation

**This is not released yet. This won't work.**
Rails 4.1 to 6.1 are supported with Ruby 2.1 to 3.0. Tested against SQLite3, PostgreSQL and MySQL. The gem
only depends on the `activerecord` gem.

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_follow_assoc'
```

And then execute:

    $ bundle install

Or install it yourself with:

    $ gem install activerecord_follow_assoc

## Usage

Starting from a query or a model, you call `follow_assoc` with an association. What you get back is another query,
but it is on the association's model, and is filtere.

So `my_comments.follow_assoc(:posts)` gives you a query on `Post` which only returns the posts that were 
related to the `my_comments`.

```
# Getting the spam comments to posts by a specific author
spam_comments = author.posts.follow_assoc(:comments).spam
```

As a shortcut, you can also give multiple association to `follow_assoc`. Doing so is equivalent to consecutive calls to it.
```
# Getting the spam comments to posts in some sections
spam_comments_in_section = my_sections.follow_assoc(:posts, :comments).spam
# Equivalent to
spam_comments_in_section = my_sections.follow_assoc(:posts).follow_assoc(:comments).spam
```

## Known issues

**No support for recursive has_one**

The SQL to do this while isolating the different layers of conditions is a mess and I worry about
the resulting performance. So for now, this will raise an exception.

**MySQL doesn't support sub-limit**

On MySQL databases, it is not possible to use has_one associations and associations with a scope that apply either a limit or an offset.

I do not know of a way to do a SQL query that can deal with all the specifics of has_one for MySQL. If you have one, then please suggest it in an issue/pull request.

In order to work around this, you must use the ignore_limit option. The behavior is less correct, but better than being unable to use the gem.

## Another recommended gem

If you feel a need for this gem's feature, you may also be interested in another of gem of mine: [activerecord_where_assoc](https://github.com/MaxLap/activerecord_where_assoc).

It allows you to make conditions based on your associations (without changing the kind of objects returned). For simple cases, they can both fit your need, but each can handle different situations.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MaxLap/activerecord_follow_assoc.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveRecordFollowAssoc project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/MaxLap/activerecord_follow_assoc/blob/master/CODE_OF_CONDUCT.md).



