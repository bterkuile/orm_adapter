require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(SimplyStored)
  puts "** require 'simply' and start couchdb to run the specs in #{__FILE__}"
else

  CouchPotato::Config.database_name = 'orm_adapter_test'


  module SimplyStoredOrmSpec
    @@created_instances = 0

    def self.created_instances
      @@created_instances
    end

    def self.created_instances=(val)
      @@created_instances = val
    end
    class User
      include SimplyStored::Couch
      property :name
      property :rating
      has_many :notes, :foreign_key => :simply_stored_orm_spec__owner_id, :class_name => 'SimplyStoredOrmSpec::Note'

      def self.create!(attrs = {})
        attrs[:created_at] ||= Time.now.utc + (SimplyStoredOrmSpec.created_instances += 1)
        super(attrs)
      end
    end

    class Note
      include SimplyStored::Couch
      property :body, :default => "made by orm"
      belongs_to :owner, :class_name => 'SimplyStoredOrmSpec::User'
    end

    # here be the specs!
    describe SimplyStored::Couch::OrmAdapter do

      before do
        CouchPotato.couchrest_database.delete! rescue nil
        CouchPotato.couchrest_database.server.create_db CouchPotato::Config.database_name
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end
