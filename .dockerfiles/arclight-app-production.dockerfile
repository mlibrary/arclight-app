FROM ruby:3.2

ARG UNAME=app-user
ARG UID=1000
ARG GID=1000

RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends vim nodejs yarn sqlite3
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d /opt/app-root -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p /gems && chown $UID:$GID /gems

USER $UNAME
COPY --chown=$UID:$GID Gemfile* /opt/app-root/

ENV BUNDLE_PATH /gems

WORKDIR /opt/app-root
RUN gem install bundler
RUN bundle install

COPY --chown=$UID:$GID . /opt/app-root/

#ENV DATABASE_URL=postgresql://postgres:arclight@db/arclight
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=f99ee1a4248cb1a6cdaaa4771320dbb1
RUN bundle exec rails assets:precompile

CMD ["bundle", "exec", "bin/rails", "s", "-b", "0.0.0.0"]