# ForemanHostReports (foreman_host_reports)

Foreman plugin providing reporting feature optimized for high-performance. The
ultimate goal is to replace Foreman core reporting functionality.

## Installation and usage

See
[How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins.

More instructions later.

## Motivation

The motivation was poor performance of the Foreman core reporting implementation. If reports are processed and stored efficiently, import process can be 20x (times) faster with less storage requirements. To achieve that, minimum processing is performed during the import phase, report is stored as-is in a database blob (text) field and only parsed when report show page is opened.

For more info and discussion about the implementation, read [a thread on discourse](https://community.theforeman.org/t/rfc-optimized-reports-storage/15573). The design is roughly the following:

* Instead of modyfing current core report functionality which is customized by various plugins, new plugin is created.
* New model class is created: `HostReport`, the reason for that is that this will be better upgrade experience, new tables can be migrated, data can be transformed and legacy tables `Report` and `ConfigReport` can be dropped afterwards. API will be completely different anyway, plugins will no longer handle directly with the model anymore.
* New API endpoint is created, this will require modifications of ENC script, Ansible and OpenSCAP.
* The API remains very same, tho with some differences. Report is sent in JSON, required HTTP argument "format" is required to allow storing reports without any input parsing (copy directly into database).
* Foreman Puppet report format is modified for better performance - instead of individual log lines, whole report body is stored in one JSON string called "body". Parsing is done during report view/download from Foreman.
* Report content is stored in new field `body` as plain text (JSON) which is compressed by default by Postgres server.
* Report origin is kept in a new `format` field (Foreman Puppet, Ansible, OpenSCAP, Plaintext). There is report format Plaintext which would be simply store report as-is without further processing.
* Status column converted from integer to 64bit big int.
* StatusCalculator is kept and extended to use all 64bits.
* Plugin decides themselves how to store data in the `body` field in such a way that it’s presentable and searchable. Plugin authors should be dis-encouraged from complex (and slow) transformations tho - transformation during view should be encouraged.
* Plugin API to implement new report formats.
* New model `ReportKeyword(id: int, report_id: int, name: varchar)` is created so plugins can create arbitrary number of keywords which are associated with Report model (M:N).
* Example keywords:
  * `PuppetHasFailedResource`
  * `PuppetHasFailedRestartResource`
  * `PuppetHasChangedResource`
  * `AnsibleHasUnreachableHost`
  * `AnsibleHasFailedTask`
  * `AnsibleHasChangedTask`
  * `ScapHasFailedRule`
  * `ScapHasOtheredRule`
  * `ScapHasHighSeverityFailure`
  * `ScapHasMediumSeverityFailure`
  * `ScapHasLowSeverityFailure`
  * `ScapFailure:xccdf_org.ssgproject.content_rule_ensure_redhat_gpgkey_installed`
  * `ScapFailure:xccdf_org.ssgproject.content_rule_security_patches_up_to_date`
* It is completely up to plugin authors which set of keywords they will generate.
* Keyword generation can be configurable, for example OpenSCAP plugin can have a list of allowed rules to report (the most important ones).
* The key is to keep amount of keywords at a reasonable level, for example OpenSCAP should not be creating `ScapPassed:xyz` keywords because there will be too many of them.
* Searching is supported via:
  * Indexed keywords (e.g. `origin = scap and keyword = ScapHasHighSeverityFailure` or simply just the keyword which will be the default scoped_search field)
  * Full text in body (slow but this will work for searching for particular line)
* Index page (search result) shows also number of failures, changes etc (using StatusCalculator).
* All searching should be by default scoped to a reasonable time frame (last week) so SQL server can quickly use index on “reported_at” column and do a quick table scan for the rest

## Report types

There are several report types implemented by this plugin.

The API REST endpoint expects the format to be also passed via HTTP argument so no input parsing is actually needed to detect format.

### Plain

The most simple format, whole contents of HTTP payload is stored in body database field without any processing. When such format is displayed, it is presented as plain/text without any transformations or formatting.

### Standard

Standard format that is optimized for fast processing and effective storage. Format, host and reported_at fields are all mandatory.

Optional field id should be set to unique number or string that represetnts the report. Optional proxy field represents FQDN of foreman proxy which processed the report.

Optional status field represent counts of levels for the report, this is stored in 64 bit array. Standard report recognizes the following levels: debug, normal, warning and error. If count exceeds the limit if unsigned 16 bits per number, report returns "65536+" for this status.

Optional field errors may contain an array of strings with errors from initial processing and transformation.

Field named all_lines is a simple string to minimize memory allocations, usually a multi-line string. The standard implementation does not perform any formatting or transformations, when implementing a new formatter it is recommended to keep all_lines field as a multi-line string and prefix lines with additional info like level or timestamp:

```
INFO:1611047686:All log lines are represented as a single multi-line string.
DEBUG:1611047687:This is a second line.
```

The standard format is good enough for standard output and error of UNIX terminal or syslog output. If multiple lines are expected (e.g. output of files for diff), JSON array should be considered instead. See Puppet format below for more details.

It is recommended to avoid performing transformations during storing of reports into database as reporting must be optimized for fast uploads. All transformations (e.g. turning all_lines into a HTML table with three columns for the example above) should be done when a report is fetched and displayed.

Whole JSON is stored in "body" database field, so additional fields can be added by implementations based on the standard report. An example standard report:

```
{
  "format": "standard",
  "id": "06b77b5d-5df5-4937-9c14-d00a2e7b927f",
  "host": "hostname.example.com",
  "proxy": "foreman-proxy.example.com",
  "reported_at": "2013-05-13 19:49:00 UTC",
  "errors": [],
  "status": {
    "debug": 0,
    "normal": 41,
    "warning": 1,
    "error": 2
  },
  "all_lines": "All log lines are represented as a single multi-line string.\nThis is a second line."
}
```

### Puppet

Report designed to fullfill needs of the legacy Foreman Puppet report based on the standard report. It shares common fields with the standard report (see above) but it has the following statuses: applied, restarted, failed, failed_restarts, skipped, pending. That's 10 bits per status with maximum value of 1024.

Instead of all_lines, contents is stored in logs array with every log being array of three elements:

* level: one of debug, info, notice, warning, err, alert, emerg, crit
* source: the puppet resource
* message: the message itself

Field resource_statuses only contains list of resources, but not more details.

Field evaluation_times contains top 30 resource names and its evaluation times plus total sum under name of "Others" for the rest.

```
{
  "format": "puppet",
  "id": "06b77b5d-5df5-4937-9c14-d00a2e7b927f",
  "host": "deb.example.com",
  "proxy": "localhost",
  "reported_at": "2021-01-19T12:40:02.831013816Z",
  "report_format": 10,
  "puppet_version": "6.16.0",
  "environment": "production",
  "metrics": {
    "resources": {
      "name": "resources",
      "label": "Resources",
      "values": [
        [
          "total",
          "Total",
          405
        ],
        [
          "skipped",
          "Skipped",
          0
        ],
        [
          "failed",
          "Failed",
          1
        ],
        [
          "failed_to_restart",
          "Failed to restart",
          0
        ],
        [
          "restarted",
          "Restarted",
          0
        ],
        [
          "changed",
          "Changed",
          0
        ],
        [
          "out_of_sync",
          "Out of sync",
          0
        ],
        [
          "scheduled",
          "Scheduled",
          0
        ],
        [
          "corrective_change",
          "Corrective change",
          0
        ]
      ]
    },
    "time": {
      "name": "time",
      "label": "Time",
      "values": [
        [
          "package",
          "Package",
          0.10441856899999999
        ],
        [
          "file",
          "File",
          0.6205165560000004
        ],
        [
          "anchor",
          "Anchor",
          0.0007514900000000001
        ],
        [
          "exec",
          "Exec",
          2.5235192609999997
        ],
        [
          "file_line",
          "File line",
          0.000395901
        ],
        [
          "mysql_datadir",
          "Mysql datadir",
          0.000380248
        ],
        [
          "service",
          "Service",
          0.187978321
        ],
        [
          "mysql_user",
          "Mysql user",
          0.000324085
        ],
        [
          "mysql_grant",
          "Mysql grant",
          0.0005333
        ],
        [
          "group",
          "Group",
          0.0016234639999999998
        ],
        [
          "shellvar",
          "Shellvar",
          0.095874028
        ],
        [
          "mounttab",
          "Mounttab",
          0.008913022
        ],
        [
          "user",
          "User",
          0.014042565000000002
        ],
        [
          "ssh_authorized_key",
          "Ssh authorized key",
          0.000289458
        ],
        [
          "augeas",
          "Augeas",
          0.075545717
        ],
        [
          "gnupg_key",
          "Gnupg key",
          0.021904382
        ],
        [
          "mailalias",
          "Mailalias",
          0.000313646
        ],
        [
          "sshd_config",
          "Sshd config",
          0.034943459
        ],
        [
          "postgresql_conf",
          "Postgresql conf",
          0.001839983
        ],
        [
          "concat_file",
          "Concat file",
          0.000588799
        ],
        [
          "concat_fragment",
          "Concat fragment",
          0.0027495480000000005
        ],
        [
          "rvm_system_ruby",
          "Rvm system ruby",
          1.384307727
        ],
        [
          "rvm_alias",
          "Rvm alias",
          1.48978911
        ],
        [
          "postgresql_conn_validator",
          "Postgresql conn validator",
          0.066834735
        ],
        [
          "postgresql_psql",
          "Postgresql psql",
          0.549115666
        ],
        [
          "cron",
          "Cron",
          0.006601505
        ],
        [
          "filebucket",
          "Filebucket",
          0.000183308
        ],
        [
          "startup_time",
          "Startup time",
          0.733938909
        ],
        [
          "node_retrieval",
          "Node retrieval",
          1.081311710178852
        ],
        [
          "plugin_sync",
          "Plugin sync",
          1.6488488875329494
        ],
        [
          "fact_generation",
          "Fact generation",
          3.781282566487789
        ],
        [
          "convert_catalog",
          "Convert catalog",
          0.9406693913042545
        ],
        [
          "config_retrieval",
          "Config retrieval",
          6.882053259760141
        ],
        [
          "transaction_evaluation",
          "Transaction evaluation",
          7.9571788385510445
        ],
        [
          "catalog_application",
          "Catalog application",
          8.027862664312124
        ],
        [
          "total",
          "Total",
          23.256689724
        ]
      ]
    },
    "changes": {
      "name": "changes",
      "label": "Changes",
      "values": [
        [
          "total",
          "Total",
          0
        ]
      ]
    },
    "events": {
      "name": "events",
      "label": "Events",
      "values": [
        [
          "total",
          "Total",
          0
        ],
        [
          "failure",
          "Failure",
          0
        ],
        [
          "success",
          "Success",
          0
        ]
      ]
    }
  },
  "logs": [
    [
      "notice",
      "//deb.example.com/Puppet",
      "Applied catalog in 8.03 seconds"
    ]
  ],
  "resource_statuses": [
    "Package[git]",
    "Package[libxml2-dev]",
    "Package[libxslt1-dev]",
    "Package[libkrb5-dev]",
    "Package[libsystemd-dev]",
    "Package[freeipmi]",
    "Package[ipmitool]",
    "Package[firefox-esr]",
    "Package[libvirt-dev]",
    "Package[asciidoc]",
    "Package[bzip2]",
    "Package[unzip]",
    "Package[ansible]",
    "Package[python-virtualenv]",
    "Package[libcurl4-openssl-dev]",
    "Package[libsqlite3-dev]",
    "Package[transifex-client]",
    "Package[java]",
    "Exec[update-java-alternatives]",
    "File_line[java-home-environment]",
    "Cron[puppet]",
    "Filebucket[puppet]"
  ],
  "keywords": [
    "PuppetResourceFailed:Package[bzip2]"
  ],
  "evaluation_times": [
    [
      "Exec[ruby-2.6.3/update_rubygems]",
      0.662541335
    ],
    [
      "Exec[ruby-2.5.1/update_rubygems]",
      0.607295328
    ],
    [
      "Exec[ruby-2.7.0/update_rubygems]",
      0.600359435
    ],
    [
      "Others",
      0.447703594
    ]
  ]
}
```

## Keywords

Each report can contain field named keyword, an array of strings. These are strings, or tags, stored in a separate table with an index and associated with the report. Keyword should be in CamelCase, prefixed with the report type (e.g. `Puppet`). Reports must avoid creating too many keywords! Typically only failures should be reported.

Example keywords:

* PuppetHasChange
* PuppetIsOutOfSync
* PuppetHasFailure
* PuppetResourceFailed:Package[git]

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2021 Lukáš Zapletal

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

