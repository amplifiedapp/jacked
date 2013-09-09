# Jacked

The gem that gets information from audio files.

## Installation

Add this line to your application's Gemfile:

    gem 'jacked'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jacked

## Usage

To initialize write:

```ruby
jacked = Jacked.create("path/to/file")
```

to get the file_type

```ruby
jacked.file_type #=> audio
```

to get the file_format

```ruby
jacked.file_format #=> mp3, wav, etc...
```

to get the duration

```ruby
jacked.duration #=> in seconds. eg.: 234
```

to get the waveform (in json format)

```ruby
jacked.waveform #=> get a json with: width, height and data
```
