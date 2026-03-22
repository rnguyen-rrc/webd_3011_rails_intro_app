# lib/tasks/areas_coordinates.rake

require "net/http"
require "json"

namespace :areas do
  desc "Update area coordinates using country codes"
  task update_coordinates: :environment do
    puts "=== START ==="

    area_to_code = {
      "Algerian"      => "DZ",
      "American"      => "US",
      "Argentinian"   => "AR",
      "Australian"    => "AU",
      "British"       => "GB",
      "Canadian"      => "CA",
      "Chinese"       => "CN",
      "Croatian"      => "HR",
      "Dutch"         => "NL",
      "Egyptian"      => "EG",
      "Filipino"      => "PH",
      "French"        => "FR",
      "Greek"         => "GR",
      "Indian"        => "IN",
      "Irish"         => "IE",
      "Italian"       => "IT",
      "Jamaican"      => "JM",
      "Japanese"      => "JP",
      "Kenyan"        => "KE",
      "Malaysian"     => "MY",
      "Mexican"       => "MX",
      "Moroccan"      => "MA",
      "Norwegian"     => "NO",
      "Polish"        => "PL",
      "Portuguese"    => "PT",
      "Russian"       => "RU",
      "Saudi Arabian" => "SA",
      "Slovakian"     => "SK",
      "Spanish"       => "ES",
      "Syrian"        => "SY",
      "Thai"          => "TH",
      "Tunisian"      => "TN",
      "Turkish"       => "TR",
      "Ukrainian"     => "UA",
      "Uruguayan"     => "UY",
      "Venezulan"     => "VE",
      "Vietnamese"    => "VN"
    }

    updated = 0
    failed = []

    Area.find_each do |area|
      code = area_to_code[area.name]

      unless code
        puts "⚠️ No code mapping for #{area.name}"
        failed << area.name
        next
      end

      url = URI("https://restcountries.com/v3.1/alpha/#{code}")

      begin
        res = Net::HTTP.get_response(url)

        unless res.is_a?(Net::HTTPSuccess)
          puts "API failed for #{area.name} (#{code})"
          failed << area.name
          next
        end

        data = JSON.parse(res.body)
        latlng = data[0]["latlng"]

        if latlng && latlng.length == 2
          area.update!(
            latitude: latlng[0],
            longitude: latlng[1]
          )
          puts "Updated #{area.name}: #{latlng[0]}, #{latlng[1]}"
          updated += 1
        else
          puts "No latlng for #{area.name}"
          failed << area.name
        end

      rescue => e
        puts "Error for #{area.name}: #{e.message}"
        failed << area.name
      end
    end

    puts "\n=== DONE ==="
    puts "Updated: #{updated}"
    puts "Failed: #{failed.join(', ')}" if failed.any?
  end
end