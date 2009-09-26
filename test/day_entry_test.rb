require 'test_helper'

class DayEntryTest < Test::Unit::TestCase
  should "read DayEntry xml" do
    entries = HCl::DayEntry.from_xml(<<-EOD)
<daily>
  <for_day type="date">Wed, 18 Oct 2006</for_day>
  <day_entries>
    <day_entry>
      <id type="integer">195168</id>
      <client>Iridesco</client>
      <project>Harvest</project>
      <task>Backend Programming</task>
      <hours type="float">2.06</hours>
      <notes>Test api support</notes>
      <timer_started_at type="datetime">
        Wed, 18 Oct 2006 09:53:06 -0000
      </timer_started_at>
      <created_at type="datetime">Wed, 18 Oct 2006 09:53:06 -0000</created_at>
    </day_entry>
  </day_entries>
</daily>
    EOD
    assert_equal 1, entries.size
    {
      :project => 'Harvest',
      :client => 'Iridesco',
      :task => 'Backend Programming',
      :notes => 'Test api support',
      :hours => '2.06',
    }.each do |method, value|
      assert_equal value, entries.first.send(method)
    end
  end

  should "append to an existing note" do
    entry = HCl::DayEntry.new(:id => '1', :notes => 'yourmom.', :hours => '1.0')
    HCl::DayEntry.stubs(:post)
    entry.append_note('hi world')
    assert_equal 'yourmom. hi world', entry.notes
  end

  should "append to an undefined note" do
    entry = HCl::DayEntry.new(:id => '1', :notes => nil, :hours => '1.0')
    HCl::DayEntry.stubs(:post)
    entry.append_note('hi world')
    assert_equal ' hi world', entry.notes
  end
  
  should "raise on errors from Harvest" do
    begin
      HCl::DayEntry.from_xml(<<-EOD)
        <?xml version="1.0" encoding="UTF-8"?>
        <error>
          <kind>InvoicedHours</kind>
          <message>    You cannot add time to
            &lt;em&gt;Customer+dev&lt;/em&gt;, because the project has been
            invoiced and locked for this time period.
        </message>
        </error>
      EOD
    rescue HCl::TimesheetResource::Failure => ohnoes
      assert_equal true, !!(ohnoes.message =~ /invoiced and locked/)
    end
  end
end
