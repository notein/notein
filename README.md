# NoteIn: Federated Note Sharing

NoteIn enables federated note-taking and sharing.
Federation is done using the [ActivityPub](https://activitypub.rocks/) protocol,
which is used by Mastodon, PeerTube, and more. Through ActivityPub NoteIn can interact with these platforms, as well as other instances of NoteIn. 

**_Please note this is alpha software, not recommended for production use,
and federation is not supported yet._**

The following setup instructions are intended for testing and development.

## Start in development mode

$ bundle install

$ cd config

$ cp config.yml.example config.yml

$ cp secrets.yml.example secrets.yml

$ cp database.yml.example database.yml

$ cd ..

$ rake db:migrate

$ rails s
