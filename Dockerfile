FROM ruby:4.0-slim

WORKDIR /app

ENV BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3"

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb ./

EXPOSE 8000

CMD ["bundle", "exec", "rubst_api", "run", "app.rb", "--host", "0.0.0.0", "--port", "8000"]
