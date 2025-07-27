FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev

WORKDIR /app

# Add Gems
COPY Gemfile* ./
RUN bundle install

# Copy app
COPY . .

# Default command
ENTRYPOINT ["ruby", "main.rb"]
