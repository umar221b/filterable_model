# FilterableModel

FilterableModel provides an organized and seamless way to filter your ActiveRecord objects using real and custom attributes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filterable_model', '~> 0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install filterable_model

## Usage

Include FilterableModel inside ApplicationRecord or directly inside your ActiveRecord model:

```ruby
class User < ApplicationRecord
  include FilterableModel
end
```

### Filtering by real attributes

To filter using the exact values of your ActiveRecord model attributes, override the `filterable_attributes` class method to return an array of whitelisted attributes:

```ruby
class User < ApplicationRecord
  include FilterableModel

  concerning :Filtering do
    class_methods do

      def filterable_attributes
        %w[id gender is_subscribed]
      end

    end
  end

end
```

### Filtering by custom attributes

Filtering using custom attributes works by calling the add_filter method and passing a block that accepts the filter-by value, and returns an `ActiveRecord::Relation`:

```ruby
class User < ApplicationRecord
  include FilterableModel

  concerning :Filtering do
    included do

      add_filter :name do |name| # search by first name or username
        where("LOWER(users.first_name) LIKE :query OR LOWER(users.username) LIKE :query", query: "%#{name.downcase}%")
      end


      add_filter :just_active do |value| # filter by users with active sessions
        if value.to_s == 'true'
          includes(:session).where(session: { active: true })
        else
          current_scope # do not change the current relation
        end
      end

    end
  end
end
```

Filter your relation by calling `filter` on your model and passing the filtering hash:

```ruby
@users = User.all

filtering_hash = {
  gender: 'male',
  is_subscribed: 'false',
  name: 'John',
  just_active: 'true'
}

@users = @users.filter(filtering_hash)
```

Passing an unknown filter will raise a `FilterNotSupported` error.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umar221b/filterable_model.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
