module Aruba
  module Api

    def check_file_json_content(file, expected_json_content, expect_match)
      prep_for_fs_check do 
        json_content = JSON.parse(IO.read(file))
        if expect_match
          json_content.should == expected_json_content
        else
          json_content.should_not == expected_json_content
        end
      end
    end
  end

end

Then /^the file "([^\"]*)" should contain the JSON:$/ do |file_name, json|
  check_file_json_content file_name, JSON.parse(json), true
end

When /pending/ do
  pending
end
