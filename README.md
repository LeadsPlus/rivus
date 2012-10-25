Welcome to Rivus
================

Rivus is an application to help you follow your remote foes easily, and
preferably in one place.

So far, it's nothing more than an RSS aggregator displaying information in a
timeline.  In that, it's kinda related to [River][river], by Dave Winer & co.
However, if Rivus isn't (yet?) real-time and as feature full, it also has very
different goals and isn't even particularly dedicated to RSS.


Project goals
-------------

Co-workers need not share the same office anymore, nor the same timezone.  For
companies that embrace, and encourage remote work, this means a need for clear
information channels.  We know of two kinds:

  * synchronous channels: IM, IRC, Campfire,
  * and asynchronous: e-mail, bug-trackers, RSS feeds, ...

Rivus is an attempt at making some of the asynchronous communication channels
available in one place.  No more, no less.  Preferably, you'd want to own the
*place* and the *data*, rather than having it duplicated say 30 times over in
Google's über-data-centers.

To help with that Rivus is distributed with an open-source license.


Is it any good?
---------------

Yes.


Is it production ready?
-----------------------

Absolutely not.  And if you can code, stop reading, now.


Wanna hack?
===========

Rivus is a Rails 3 application, using a MongoDB store.  It runs over unicorns,
with a bunch of sidekiqs (welcome to Ruby-land).

What can it do?
---------------

So far, Rivus reads information provided by:

  * Your github news feed,
  * whatever RSS or Atom feed,

and displays it in a neat timeline.

While you can get this through your bona fide feed-reader, other sources are
planned that may not be available as easily through RSS.  In no particular
order:

  * [Trello][trello] activities and notifications,
  * mails from your favorite IMAP server,
  * Twitter search and/or user timeline (BTw Twitter does a great job at
    removing useful things, like RSS),
  * other social networking things with nicer open protocols like OStatus, or
    Tent,
  * you get the idea.

Since this would be a very static and messy timeline to view, you are welcome
to suggest how you think this informations should be organized.  Cool
user-interface ideas welcome too.  For starters we want very basic things:

  * a search box,
  * a bunch of filters to hide, file, or notify of interesting stuff,
  * tags because it's can't be hard, right?
  * and favorites because everybody loves putting little stars next to stuff
    they like.

Setup
-----

You'll need the Bundler gem, and ruby 1.9.

  * Run `bundle install`,
  * Copy `config/gaston/sources.yml.sample` to `config/gaston/sources.yml`,
  * Copy `config/mongoid/mongoid.yml.sample` to `config/mongoid.yml`,
  * Configure the files you just copied (use your brain),
  * Run `bundle exec forman start`.
  * The development environment should be available on http://localhost:3000/


TODO
----

This list belongs in a TODO, or Roadmap file.  If you don't like lists, sorry.

  * Code cleanup: while it was fine to bootstrap fast, the project does a few
    (and hopefully, only a few) things wrong. These must be fixed before more
    cruft can be added.
      * Source model:
        * extract authorization
        * separate concerns (GH, and RSS handling should be in separate
          entities, that kind of things).
      * Auth controller code is weak.
      * Confirmable subscriptions if we stick to pure e-mail and passwords.
      * Omniauth to sign-up with external accounts would be a better approach.
  * Describe setup and installation steps
  * More Sources!
    * Finalize the Github source's views
    * Trello
    * IMAP
    * Update the RSS/Atom source to use PubSubHubbub
    * Twitter
    * OStatus
    * Tent ?
  * A nicer buzzwordy HTML5 interface (Backbone's bootstrapped already).
  * Search (ElasticSearch...)
  * Filters
  * Tagging
  * Source groups
  * Sharing (meh).

* * * *

Author
======

This was started during Rails Rumble by [oz](https://github.com/oz).  You can
send him more coffee if he does not code well.  Patches or pull-requests are
also welcome.  If you can buy him free time, he's game too.


License
=======

Rivus is licensed under the GPL v3.


[trello]: https://trello.com/
[river]: http://newsriver.org/
