# frozen_string_literal: true
require 'csv'
require 'mongo'
require 'mongoid'
require 'mongoid/geospatial'
require 'kaminari/mongoid'
require 'date'
require 'json'
require 'awesome_print'
require 'yaml'


class MobileFoodFacility
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial


  field :location_id, type: Integer
  field :applicant, type: String
  field :facility_type, type: String
  field :cnn, type: Integer
  field :location_description, type: String
  field :address, type: String
  field :permit, type: String
  field :status, type: String
  field :food_items, type: String
  field :latitude, type: Float
  field :longitude, type: Float
  field :schedule, type: String
  field :days_hours, type: String
  field :approved, type: String
  field :location_gps_string, type: String
  field :location_gps, type: Point, spatial: true # 2d

  # The following fields are not really interesting for us right now
  # field :noi_sent, type: Integer # ??
  # field :received, type: Date
  # field :expiration_date, type: DateTime
  # field :x, type: Integer
  # field :y, type: Integer
  # field :block_lot, type: Integer
  # field :block, type: Integer

  validates :location_id, presence: true
  index({ location_id: 1 }, { unique: true })


  scope :applicant, ->(applicant) { where(applicant: /#{applicant}/) }
  scope :food_items, ->(food_items) { where(food_items: /#{food_items}/) }
  scope :facility_type, ->(facility_type) { where(facility_type: facility_type) }


  def self.as_json(*args)
    res = super
    #res["id"] = res.delete("_id").to_s
    #res
  end

  def self.load_data_set
    MobileFoodFacility.delete_all
    MobileFoodFacility.create_indexes

    data_file = './sample-data/Mobile_Food_Facility_Permit.csv'
    data = CSV.foreach(data_file, headers: true).map(&:to_h)
    data.each do |row|
      begin
        mff = MobileFoodFacility.new
        mff.location_id = row['locationid'].to_i
        mff.applicant = row['Applicant']
        mff.facility_type = row['FacilityType']
        mff.cnn = row['cnn'] = row['cnn'].to_i
        mff.location_description = row['LocationDescription']
        mff.address = row['Address']
        mff.permit  = row['permit']
        mff.status = row['Status']
        mff.food_items = row['FoodItems']
        mff.latitude = row['Latitude'].to_f
        mff.longitude = row['Longitude'].to_f
        mff.schedule = row['Schedule']
        mff.days_hours = row['DaysHours']
        mff.approved = row['Approved']
        mff.location_gps_string = row['Location']
        mff.location_gps = { lat: row['Latitude'].to_f, lng: row['Longitude'].to_f }
        mff.upsert(replace: true)
      rescue StandardError => e
        p "ERROR( #{e.message} ): Row rejeted: #{e}"
      end
    end
  end
end
