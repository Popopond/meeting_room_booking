require "application_system_test_case"

class CheckInsTest < ApplicationSystemTestCase
  setup do
    @check_in = check_ins(:one)
  end

  test "visiting the index" do
    visit check_ins_url
    assert_selector "h1", text: "Check ins"
  end

  test "should create check in" do
    visit check_ins_url
    click_on "New check in"

    fill_in "Booking", with: @check_in.booking_id
    fill_in "Check in", with: @check_in.check_in
    fill_in "Created at", with: @check_in.created_at
    fill_in "User", with: @check_in.user_id
    click_on "Create Check in"

    assert_text "Check in was successfully created"
    click_on "Back"
  end

  test "should update Check in" do
    visit check_in_url(@check_in)
    click_on "Edit this check in", match: :first

    fill_in "Booking", with: @check_in.booking_id
    fill_in "Check in", with: @check_in.check_in.to_s
    fill_in "Created at", with: @check_in.created_at.to_s
    fill_in "User", with: @check_in.user_id
    click_on "Update Check in"

    assert_text "Check in was successfully updated"
    click_on "Back"
  end

  test "should destroy Check in" do
    visit check_in_url(@check_in)
    click_on "Destroy this check in", match: :first

    assert_text "Check in was successfully destroyed"
  end
end
