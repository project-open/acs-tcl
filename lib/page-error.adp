<%
# Write out HTTP headers
set header_vars [ns_conn headers]
set electron_agent_p 0
foreach var [ad_ns_set_keys $header_vars] {
    set value [ns_set get $header_vars $var]
    ns_log Notice "page-error: header: $var: $value"

    if {"User-Agent" eq $var} {
	if {[regexp {Electron/2} $value match]} { set electron_agent_p 1 }
    }
}
%>

<if 1 eq @electron_agent_p@>

<if @top_message@ not nil>@top_message;noquote@</if>
<if @message@ not nil    >@message;noquote@</if>
<if @stacktrace@ not nil >@stacktrace;noquote@</if>

</if>
<else>
<!-- This page goes into /packages/apm-tcl/lib/page-error.adp -->
<master>
<property name="doc(title)">#acs-tcl.Server#</property>


<p>
<if @top_message@ not nil>
	@top_message;noquote@
</if>
<else>
  #acs-tcl.There#
</else>
</p>

<% set error_url [im_url_with_query] %>
<% set error_location "[ns_info address] on $::tcl_platform(platform)" %>
<% set report_url [parameter::get -package_id [im_package_core_id] -parameter "ErrorReportURL" -default ""] %>
<% set system_url [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemURL -default ""] %>
<% set first_names "undefined" %>
<% set last_name "undefined" %>
<% set email "undefined" %>
<% set username "undefined" %>
<% set current_user_id [auth::require_login] %>
<% if {"" eq $current_user_id} { set current_user_id 0} %>
<% db_0or1row user_info "select * from cc_users where user_id=:current_user_id" %>
<% set publisher_name [parameter::get -package_id [ad_acs_kernel_id] -parameter PublisherName -default ""] %>
<% set package_versions [db_list package_versions "select v.package_key||':'||v.version_name from (select max(version_id) as version_id, package_key from apm_package_versions group by package_key) m, apm_package_versions v where m.version_id = v.version_id"] %>
<% set system_id [im_system_id] %>
<% set hardware_id [im_hardware_id] %>
<% if {![info exists error_content]} { set error_content "" } %>
<% if {![info exists error_content_filename]} { set error_content_filename "" } %>
<% if {![info exists error_type]} { set error_type "default" } %>
<% if {![info exists top_message]} { set top_message "" } %>
<% if {![info exists bottom_message]} { set bottom_message "" } %>

<%
set error_email [parameter::get -package_id [im_package_core_id] -parameter "ErrorReportEmail" -default "fraber@fraber.de"]
if {"" ne $error_email} {
    catch {
	set sender_email [im_parameter -package_id [ad_acs_kernel_id] SystemOwner "" [ad_system_owner]]
	set first_error_line [lindex [split $stacktrace "\n"] 0]
	set subject "$system_url: $first_error_line"
	acs_mail_lite::send \
	    -send_immediately \
	    -to_addr $error_email \
	    -from_addr $sender_email \
	    -subject $subject \
	    -body $stacktrace
    }
}


%>


<br>
<form action="@report_url;noquote@" method=POST>
<input type=submit name=submit value="Report this Error">
<br>
<input type=checkbox name=privacy_statement_p checked>
I agree with the <a href="http://www.project-open.com/en/legal-note" target="_">privacy statement</a>.
<br>
<input type=hidden name=error_url value=@error_url@>
<input type=hidden name=error_location value=@error_location@>
<input type=hidden name=system_url value=@system_url@>
<input type=hidden name=error_first_names value=@first_names;noquote@>
<input type=hidden name=error_last_name value=@last_name;noquote@>
<input type=hidden name=error_user_email value=@email;noquote@>
<input type=hidden name=error_type value=@error_type;noquote@>
<input type=hidden name=package_versions value="@package_versions;noquote@">
<input type=hidden name=publisher_name value="@publisher_name;noquote@">
<input type=hidden name=system_id value=@system_id@>
<input type=hidden name=hardware_id value=@hardware_id@>
<input type=hidden name=platform value="<%=$::tcl_platform(platform)%>">
<input type=hidden name=os value="<%=$::tcl_platform(os)%>">
<input type=hidden name=os_version value="<%=$::tcl_platform(osVersion)%>">


<if @message@ not nil>
  <input type=hidden name=error_message value="@message;noquote@">
</if>
<if @stacktrace@ not nil>
  <input type=hidden name=error_info value="@stacktrace@">
</if>
<input type=hidden name=error_content value='@error_content@'>
<input type=hidden name=error_content_filename value='@error_content_filename@'>
</form>
<br>

<if @bottom_message@ not nil>
	@bottom_message;noquote@
</if>

<if @message@ not nil>
  <p>
    @message;noquote@
  </p>
</if>

<if @stacktrace@ not nil>

  <p>
    Here is a detailed dump of what took place at the time of the error, which may assist a programmer in tracking down the problem:
  </p>

  <blockquote><pre>@stacktrace@</pre></blockquote>
</if>
<else>
  <p>
    The error has been logged and will be investigated by our system programmers.
  </p>
</else>


<!-- if not electron -->
</else>


