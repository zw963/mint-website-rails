# == Schema Information
#
# Table name: packages
#
#  id         :integer          not null, primary key
#  repository :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stars      :integer
#  pushed_at  :datetime
#

class Package < ActiveRecord::Base
  has_many :versions, dependent: :delete_all
  has_one :latest_version, class_name: :Version

  scope :recent, lambda {
    order(pushed_at: :desc)
  }

  scope :search, lambda {
    joins(:versions)
      .includes(:latest_version)
      .where("
        version =
         (SELECT   version
          FROM     versions
          WHERE    package_id = packages.id
          ORDER BY String_to_array(version, '.')::INT[] DESC limit 1)
      ")
      .distinct
      .order(stars: :desc)
  }

  def author
    repository.split('/').first
  end

  def repo
    repository.split('/').last
  end

  def to_param
    repository
  end
end
