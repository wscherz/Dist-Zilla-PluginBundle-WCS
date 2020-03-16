use strict;
use warnings;

use 5.014;

package Dist::Zilla::PluginBundle::WCS;

# ABSTRACT: WCS distribution build

use Moose;
use Dist::Zilla;
with
  'Dist::Zilla::Role::PluginBundle::Easy',
  'Dist::Zilla::Role::PluginBundle::PluginRemover',
  'Dist::Zilla::Role::PluginBundle::Config::Slicer';

=head1 DESCRIPTION

This is the plugin bundle that WCS uses.  It is equivalent to:

  [Git::NextVersion]
  [License]
  [CopyFilesFromBuild]
  copy = LICENSE

  [Git::GatherDir]
  exclude_filename = LICENSE

  [PkgVersion]
  die_on_existing_version = 1
  die_on_line_insertion = 1

  [NextRelease]
  timezone = America/Chicago
  format = %-9v %{yyyy-MM-dd}d

  [@Git]
  remotes_must_exist = 0
  push_to = 'origin master:master'
  push_to = 'origin release/master:release/master
  push_to = 'backup master:master'

  [@Filter]
  -bundle = @Basic
  -remove = License
  -remove = GatherDir

  [InstallGuide]
  [Git::Contributors]
  [GithubMeta]
  [MetaConfig]
  [MetaJSON]
  [MinimumPerlFast]
  [PodWeaver]
  [ReadmeAnyFromPod
  type = markdown
  filename = README.md
  location = root

  [AutoPrereqs]
  [TravisYML]
  build_release = /^release\/.*/
  post_before_install = cpanm --quiet --notest Pod::Weaver::Section::Contributors
  post_before_install = cpanm --quiet --notest Pod::Elemental::Transformer::List
  post_before_install = cpanm --quiet --notest Pod::Coverage::TrustPod
  post_before_install = cpanm --quiet --notest Test::CPAN::Meta
  perl_version = 5.30 5.28 5.26 5.24 5.22 5.20 5.18 5.16 5.14
  mvdt = 1

  [MetaTests]
  [TravisCI::StatusBadge]
  [Test::NoTabs]
  [Test::EOL]
  trailing_whitespace = 1
  all_reasons = 1

  [Test::Compile]
  [PodSyntaxTests]
  [PodCoverageTests]
  [Test::Pod::No404s]
  [Test::ReportPrereqs]
  [Test::Perl::Critic]
  [Test::Kwalitee]
  [Git::CommitBuild]
  branch =
  release_branch = release/%b
  release_message = Build release of %v (on %b)

  [TestRelease]
  [ConfirmRelease]

=cut

use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;

sub configure {
    my ($self) = @_;

    $self->add_plugins(
        'Git::NextVersion',
        'License',
        [ CopyFilesFromBuild => { copy             => 'LICENSE', } ],
        [ 'Git::GatherDir'   => { exclude_filename => 'LICENSE', } ],
        [
            PkgVersion => {
                die_on_existing_version => 1,
                die_on_line_insertion   => 1,
            }
        ],
        [
            NextRelease => {
                timezone => 'America/Chicago',
                format   => '%-9v %{yyyy-MM-dd}d',
            }
        ],
    );

    $self->add_bundle(
        '@Git' => {
            remotes_must_exist => 0,
            push_to            => [ 'origin', 'backup', ]
        }
    );

    $self->add_bundle(
        '@Filter' => {
            '-bundle' => '@Basic',
            '-remove' => [ 'License', 'GatherDir' ],
        }
    );

    $self->add_plugins(
        qw/
          InstallGuide
          Git::Contributors
          GithubMeta
          MetaConfig
          MetaJSON
          MinimumPerlFast
          PodWeaver
          /,
        [
            ReadmeAnyFromPod => {
                type     => 'markdown',
                filename => 'README.md',
                location => 'root',
            }
        ],
        qw/
          TaskWeaver
          AutoPrereqs
          /,
        [
            TravisYML => {
                build_branch        => '/^release\/.*/',
                post_before_install => [
                    'cpanm --quiet --notest Pod::Weaver::Section::Contributors',
                    'cpanm --quiet --notest Pod::Elemental::Transformer::List',
                    'cpanm --quiet --notest Pod::Coverage::TrustPod',
                    'cpanm --quiet --notest Test::CPAN::Meta'
                ],
                perl_version => [
                    '5.30', '5.28', '5.26', '5.24', '5.22', '5.20',
                    '5.18', '5.16', '5.14'
                ],
                mvdt => '1',
            }
        ],
        qw/
          MetaTests
          TravisCI::StatusBadge
          Test::NoTabs
          /,
        [
            'Test::EOL' => {
                trailing_whitespace => 1,
                all_reasons         => 1,
            }
        ],
        qw/
          Test::Compile
          PodSyntaxTests
          PodCoverageTests
          Test::Pod::No404s
          Test::ReportPrereqs
          Test::Perl::Critic
          Test::Kwalitee
          /,
        [
            'Git::CommitBuild' => {
                branch          => '',
                release_branch  => 'release/%b',
                release_message => 'Build release of %v (on %b)'
            }
        ],
        qw/
          TestRelease
          ConfirmRelease
          /,
    );
}

=begin Pod::Coverage

  configure

=end Pod::Coverage

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;
