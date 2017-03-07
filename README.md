[![Gem Version](https://badge.fury.io/rb/active_record-acts_as.svg)](http://badge.fury.io/rb/active_record-acts_as)
[![Build Status](https://travis-ci.org/krautcomputing/active_record-acts_as.svg)](https://travis-ci.org/krautcomputing/active_record-acts_as)
[![Code Climate](https://codeclimate.com/github/krautcomputing/active_record-acts_as.png)](https://codeclimate.com/github/krautcomputing/active_record-acts_as)
[![Coverage Status](https://coveralls.io/repos/krautcomputing/active_record-acts_as/badge.png)](https://coveralls.io/r/krautcomputing/active_record-acts_as)
[![Dependency Status](https://gemnasium.com/krautcomputing/active_record-acts_as.svg)](https://gemnasium.com/krautcomputing/active_record-acts_as)

# ActiveRecord::ActsAs

This is a refactor of [`acts_as_relation`](https://github.com/hzamani/acts_as_relation)

Simulates multiple-table-inheritance (MTI) for ActiveRecord models.
By default, ActiveRecord only supports single-table inheritance (STI).
MTI gives you the benefits of STI but without having to place dozens of empty fields into a single table.

Take a traditional e-commerce application for example:
A product has common attributes (`name`, `price`, `image` ...),
while each type of product has its own attributes:
for example a `pen` has `color`, a `book` has `author` and `publisher` and so on.
With multiple-table-inheritance you can have a `products` table with common columns and
a separate table for each product type, i.e. a `pens` table with `color` column.

## Requirements

* Ruby >= 2.2
* ActiveSupport >= 4.2
* ActiveRecord >= 4.2

## Installation

Add this line to your application's Gemfile:

    gem 'active_record-acts_as'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record-acts_as

## Usage

Back to example above, all you have to do is to mark `Product` as `actable` and all product type models as `acts_as :product`:

```Ruby
class Product < ActiveRecord::Base
  actable
  belongs_to :store

  validates_presence_of :name, :price

  def info
    "#{name} $#{price}"
  end
end

class Pen < ActiveRecord::Base
  acts_as :product
end

class Book < ActiveRecord::Base
  # In case you don't wish to validate
  # this model against Product
  acts_as :product, validates_actable: false
end

class Store < ActiveRecord::Base
  has_many :products
end
```

and add foreign key and type columns to products table as in a polymorphic relation.
You may prefer using a migration:

```Ruby
change_table :products do |t|
  t.integer :actable_id
  t.string  :actable_type
end
```

or use shortcut `actable`

```Ruby
change_table :products do |t|
  t.actable
end
```

**Make sure** that column names do not match on parent and subclass tables,
that will make SQL statements ambiguous and invalid!
Specially **DO NOT** use timestamps on subclasses, if you need them define them
on parent table and they will be touched after submodel updates (You can use the option `touch: false` to skip this behaviour).

Now `Pen` and `Book` **acts as** `Product`, i.e. they inherit `Product`s **attributes**,
**methods** and **validations**. Now you can do things like these:

```Ruby
Pen.create name: 'Penie!', price: 0.8, color: 'red'
  # => #<Pen id: 1, color: "red">
Pen.where price: 0.8
  # => [#<Pen id: 1, color: "red">]
pen = Pen.where(name: 'new pen', color: 'black').first_or_initialize
  # => #<Pen id: nil, color: "black">
pen.name
  # => "new pen"
Product.where price: 0.8
  # => [#<Product id: 1, name: "Penie!", price: 0.8, store_id: nil, actable_id: 1, actable_type: "Pen">]
pen = Pen.new
pen.valid?
  # => false
pen.errors.full_messages
  # => ["Name can't be blank", "Price can't be blank", "Color can't be blank"]
Pen.first.info
  # => "Penie! $0.8"
```

On the other hand you can always access a specific object from its parent by calling `specific` method on it:

```Ruby
Product.first.specific
  # => #<Pen ...>
```

If you have to come back to the parent object from the specific, the `acting_as` returns the parent element:

```Ruby
Pen.first.acting_as
  # => #<Product ...>
```

In `has_many` case you can use subclasses:

```Ruby
store = Store.create
store.products << Pen.create
store.products.first
  # => #<Product: ...>
```

You can give a name to all methods in `:as` option:

```Ruby
class Product < ActiveRecord::Base
  actable as: :producible
end

class Pen < ActiveRecord::Base
  acts_as :product, as: :producible
end

change_table :products do |t|
  t.actable as: :producible
end
```

`acts_as` support all `has_one` options, where defaults are there:
`as: :actable, dependent: :destroy, validate: false, autosave: true`

Make sure you know what you are doing when overwriting `validate` or `autosave` options.

You can pass scope to `acts_as` as in `has_one`:

```Ruby
acts_as :person, -> { includes(:friends) }
```

`actable` support all `belongs_to` options, where defaults are these:
`polymorphic: true, dependent: :destroy, autosave: true`

Make sure you know what you are doing when overwriting `polymorphic` option.


## Migrating from acts_as_relation

Replace `acts_as_superclass` in models with `actable` and if you where using
`:as_relation_superclass` option on `create_table` remove it and use `t.actable` on column definitions.


## RSpec custom matchers

To use this library custom RSpec matchers, you must require the `rspec/acts_as_matchers` file.

Examples:

```Ruby
require "active_record/acts_as/matchers"

RSpec.describe "Pen acts like a Product" do
  it { is_expected.to act_as(:product) }
  it { is_expected.to act_as(Product) }

  it { expect(Person).to act_as(:product) }
  it { expect(Person).to act_as(Product) }
end

RSpec.describe "Product is actable" do
  it { expect(Product).to be_actable }
end
```

## Contributing

1. Fork it ( https://github.com/krautcomputing/active_record-acts_as/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test changes don't break anything (`rspec`)
4. Add specs for your new feature
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request
