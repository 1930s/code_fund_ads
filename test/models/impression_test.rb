# == Schema Information
#
# Table name: impressions
#
#  id                :uuid             not null
#  advertiser_id     :bigint(8)        not null
#  campaign_id       :bigint(8)        not null
#  campaign_name     :string           not null
#  property_id       :bigint(8)        not null
#  property_name     :string           not null
#  ip                :string           not null
#  user_agent        :text             not null
#  country_code      :string
#  postal_code       :string
#  latitude          :decimal(, )
#  longitude         :decimal(, )
#  payable           :boolean          default(FALSE), not null
#  reason            :string
#  displayed_at      :datetime         not null
#  displayed_at_date :date             not null
#  clicked_at        :datetime
#  fallback_campaign :boolean          default(FALSE), not null
#

require "test_helper"

class ImpressionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
