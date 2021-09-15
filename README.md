This gem is still a work in progress. It hasn't been released yet.

# ActiveRecord Follow Assoc

![Test supported versions](https://github.com/MaxLap/activerecord_follow_assoc/workflows/Test%20supported%20versions/badge.svg)

Let's say that, in your Rails app, you want to get all of the comments to the recent posts the
current user made.

Think of how you would do it.

Here's how this gem allows you to do it:

```ruby
current_user.posts.recent.follow_assoc(:comments)
```

The `follow_assoc` method, added by this gem allows you to query the specified association 
of the records that the current query would return.

Here is a more complete [introduction to this gem](INTRODUCTION.md).

Benefits of `follow_assoc`:
* Works the same way for all kinds of association `belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many`
* You can use `where`, `order` and other such methods on the result
* By nesting SQL queries, the only records that need to be loaded are the final ones, so the above example
  wouldn't have loaded any `Post` from the database. This usually leads to faster code.
* You avoid many [problems with the alternative options](ALTERNATIVES_PROBLEMS.md).

## Why / when do you need this?

As applications grow, you can end up with quite complex data model and even more complex business rules. You may end up
needing to fetch records that are deep in your associations.

As a simple example, let's say you have a helper which receives sections of a blog and must return the recent comments
in those sections.
```ruby
def recent_comments_within(sections)
  sections.follow_assoc(:posts, :comments).recent
end
```

Note that this won't work if `sections` is an `Array`. `follow_assoc` is available in the same places as `where`. See [Usage](#Usage) for details.

Doing this without follow_assoc can be verbose, error-prone and less efficient depending on the approach taken.

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

Starting from a query or a model, you call `follow_assoc` with an association's name. It returns another query that:

* searches in the association's model
* has a `where` to only return the records that are associated with the records that the initial query would have returned.

So `my_comments.follow_assoc(:posts)` gives you a query on `Post` which only returns the posts that are
associated to the records of `my_comments`.

```ruby
# Getting the spam comments to posts by a specific author
spam_comments = author.posts.follow_assoc(:comments).spam
```

As a shortcut, you can also give multiple association to `follow_assoc`. Doing so is equivalent to consecutive calls to it.
```ruby
# Getting the spam comments to posts in some sections
spam_comments_in_section = my_sections.follow_assoc(:posts, :comments).spam
# Equivalent to
spam_comments_in_section = my_sections.follow_assoc(:posts).follow_assoc(:comments).spam
```

The `follow_assoc` method is only available on models and queries (also often called relation or scope). You cannot use
it on an `Array` of record. If you need to use `follow_assoc` in that situation, then you must make a query yourself:
```ruby
sections_query = Section.where(id: my_sections)
# Then you can use `follow_assoc`
spam_comments_in_section = sections_query.follow_assoc(:posts, :comments).spam
```

Detailed doc is [here](https://maxlap.dev/activerecord_follow_assoc/ActiveRecordFollowAssoc/QueryMethods.html).

## Known issues

**No support for recursive has_one**

The SQL to handle recursive has_one while isolating the different layers of conditions is a mess and I worry about
the resulting performance. So for now, this will raise an exception. You can use the `ignore_limit: true` option
to treat the has_one as a has_many.

**MySQL doesn't support sub-limit**

On MySQL databases, it is not possible to use has_one associations.

I do not know of a way to do a SQL query that can deal with all the specifics of has_one for MySQL. If you have one, then please suggest it in an issue/pull request.

In order to work around this, you must use the `ignore_limit: true` option, which means that the `has_one` will be treated
like a `has_many`.

## Another recommended gem

If you feel a need for this gem's feature, you may also be interested in another gem I made: [activerecord_where_assoc](https://github.com/MaxLap/activerecord_where_assoc).

It allows you to make conditions based on your associations (without changing the kind of objects returned). For simple cases, it's possible that both can build the query your need, but each can handle different situations. Here is an example:

```ruby
# Find every posts that have comments by an admin
Post.where_assoc_exists([:comments, :author], &:admins)
```

This could be done with `follow_assoc`: `User.admins.follow_assoc(:comments, :post)`. But if you wanted conditions on
a second association, then `follow_assoc` wouldn't work. It all depends on the context where you need to do the query
and what starting point you have.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MaxLap/activerecord_follow_assoc.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveRecordFollowAssoc project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/MaxLap/activerecord_follow_assoc/blob/master/CODE_OF_CONDUCT.md).



