# ForemanHostReports (foreman_host_reports)

Foreman plugin providing reporting feature optimized for high-performance. The
ultimate goal is to replace Foreman core reporting functionality.

## Installation and usage

See
[How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins.

More instructions later.

## Report types

There are several report types implemented by this plugin.

The API REST endpoint expects the format to be also passed via HTTP argument so
no input parsing is actually needed to detect format.

### Plain text

Plain format can be used for unknown formats as a fallback or to upload
arbitrary log file into Foreman.

Optional field id should be set to unique number or string that represetnts the
report. Optional proxy field represents FQDN of foreman proxy which processed
the report.

Optional summary fields change, nochange and failure are integers which have
different semantics for each type. For more information about the mapping, read
[the initial design
discussion](https://community.theforeman.org/t/new-config-report-summary-columns/26531).
For plain reports, summary fields are not used tho.

Field named body is a simple string to minimize memory allocations,
usually a multi-line string. The plain implementation does not perform any
formatting or transformations, when implementing a new formatter it is
recommended to keep body field as a multi-line string and prefix lines
with additional info like level or timestamp:

```
INFO:1611047686:All log lines are represented as a single multi-line string.
DEBUG:1611047687:This is a second line.
```

The plain format is good enough for plain output and error of UNIX
terminal or syslog output. If multiple lines are expected (e.g. output of files
for diff), JSON array should be considered instead. See Puppet format below for
more details.

It is recommended to avoid performing transformations during storing of reports
into database as reporting must be optimized for fast uploads. All
transformations (e.g. turning body into a HTML table with three columns
for the example above) should be done when a report is fetched and displayed.

Example:

```
{
  "format": "plain",
  "id": "06b77b5d-5df5-4937-9c14-d00a2e7b927f",
  "host": "hostname.example.com",
  "proxy": "foreman-proxy.example.com",
  "reported_at": "2013-05-13 19:49:00 UTC",
  "change" : 0,
  "nochange" : 0,
  "failure" : 0,
  "body": "All log lines are represented as a single multi-line string.\nThis is a second line."
}
```

#### Keywords

Each report can contain field named keyword, an array of strings. These are
strings, or tags, stored in a separate table with an index and associated with
the report. Keyword should be in CamelCase, prefixed with the report type (e.g.
`Puppet`).

### Puppet

Report designed to fullfill needs of the legacy Foreman Puppet report based on
the plain report. A lot of information is passed unchanged from the original
puppet YAML report, some detailed information is dropped for smaller size tho.

Contents (log lines) is stored in logs array with every log being array of
three elements:

* level: one of debug, info, notice, warning, err, alert, emerg, crit
* source: the puppet resource
* message: the message itself

Field `resource_statuses` only contains list of resources, but not more details.

Field `evaluation_times` contains top 30 resource names and its evaluation times
plus total sum under name of "Others" for the rest.

#### Examples

To see examples of puppet reports, visit [snapshot directory](test/snapshots).

#### Keywords

For more info read [keywords mapping initial discussion thread]
(https://community.theforeman.org/t/rfc-optimized-reports-storage/15573).

Example keywords:

* PuppetStatusChanged
* PuppetNoop
* PuppetOutOfSync

### Ansible

Ansible report also shares common fields with the plain report (format,
version, host, reported_at, proxy). The body contains JSON representation of
Ansible report without any changes.

Values which were reported as `None` (`nil` in Python) are filtered off tho to
keep the report size small as Ansible tend to report many of these.

#### Examples

To see examples of puppet reports, visit [snapshot directory](test/snapshots).

#### Keywords

For more info read [keywords mapping initial discussion thread]
(https://community.theforeman.org/t/rfc-optimized-reports-storage/15573).

Example keywords:

* AnsibleChanged
* AnsibleRescued

## Motivation and initial design

For more info and discussion about the implementation, read [a thread on
discourse](https://community.theforeman.org/t/rfc-optimized-reports-storage/15573).

## Contributing

Fork and send a Pull Request. Thanks!

## License

GNU GPLv3, see LICENSE file for more information.

## Copyright

Copyright (c) 2021 Red Hat, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

