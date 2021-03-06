%define packager       patrick330602 <wotingwu@live.com>

%define _topdir        HOMEPLACEHOLDER/rpm_wslu
%define _tmppath       /var/tmp
 
%define _rpmtopdir     %{_topdir}
%define _builddir      %{_rpmtopdir}/BUILD
%define _rpmdir        %{_rpmtopdir}/RPMS
%define _sourcedir     %{_rpmtopdir}/SOURCES
%define _specdir       %{_rpmtopdir}/SPECS
%define _srcrpmdir     %{_rpmtopdir}/SRPMS
Summary: Windows 10 Linux Subsystem Utilities
Name: wslu
Version: BUILDVERPLACEHOLDER
Release: 1
Source: wslu-BUILDVERPLACEHOLDER.tar.gz
Requires: bc imagemagick
Requires(post): %{_sbindir}/update-alternatives
Requires(postun): %{_sbindir}/update-alternatives
URL: https://github.com/wslutilities/wslu/
License: LGPLv3
%description
This is a collection of utilities for Windows 10 Linux Subsystem, such as converting WSL path to Windows path or creating your favorite linux app shortcuts on Windows 10 Desktop. Requires Windows 10 Creators Update and higher.
%prep
%setup
%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p ${RPM_BUILD_ROOT}/usr/bin
mkdir -p ${RPM_BUILD_ROOT}/usr/share/wslu
mkdir -p ${RPM_BUILD_ROOT}/usr/lib/mime/packages
install -m 755 wsl* ${RPM_BUILD_ROOT}%{_bindir}
install -m 555 etc/wsl.ico ${RPM_BUILD_ROOT}/usr/share/wslu
install -m 555 etc/runHidden.vbs ${RPM_BUILD_ROOT}/usr/share/wslu

%post
%{_sbindir}/update-alternatives --install %{_bindir}/www-browser www-browser %{_bindir}/wslview 1
%{_sbindir}/update-alternatives --install %{_bindir}/x-www-browser x-www-browser %{_bindir}/wslview 1

%postun
%{_sbindir}/update-alternatives --remove www-browser %{_bindir}/wslview
%{_sbindir}/update-alternatives --remove x-www-browser %{_bindir}/wslview
 
%clean
rm -rf $RPM_BUILD_ROOT
%files
%defattr(-,root,root)
%attr(755,root,root) %{_bindir}/wslusc
%attr(755,root,root) %{_bindir}/wslfetch
%attr(755,root,root) %{_bindir}/wslsys
%attr(755,root,root) %{_bindir}/wslupath
%attr(755,root,root) %{_bindir}/wslview
%attr(555,root,root) /usr/share/wslu/runHidden.vbs
%attr(555,root,root) /usr/share/wslu/wsl.ico
%changelog
* Mon Nov 12 2018 patrick330602 <wotingwu@live.com>
- wslusc: add env and name param;
- wslusc: add icon conversion feature(.svg/.png);
- wslfetch: add WLinux ASCII art;
- project: improved structure/license change;
- project: build structure minor change;
- project: new improved multilingual README.

