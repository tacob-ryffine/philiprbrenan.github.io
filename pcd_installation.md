Install [Dita::PCD](https://metacpan.org/pod/Dita::PCD) by copying and pasting the commands below into a terminal on a
computer with [Ubuntu 18](https://ubuntu.com/download/desktop) installed.

    sudo apt update                                                               # Install Linux and Perl modules
    sudo apt -y install curl geany geany-plugins libspice-client-glib-2.0-dev build-essential sharutils unoconv mc zip unzip qemu-kvm openjdk-11-jdk-headless at pmount openssh-server obs-studio moreutils xournal libx11-dev libpng-dev libjpeg-dev libcairo-dev libglib2.0-dev libgirepository1.0-dev libpango1.0-dev gtk+-3.0-dev dos2unix poppler-utils samba p7zip rename html-xml-utils secure-delete rar unrar
    sudo cpan install Test::SharedFork Module::Build Data::Edit::Xml::Lint Aws::Polly::Select Digest::SHA1 Google::Translate::Languages Unicode::UTF8 CPAN::Uploader Test2::Bundle::More Parse::CSV Acme::Tools Glib::Object::Introspection Glib Gtk3 Text::Hunspell CGI Data::GUID Data::Send::Local Digest::SHA1 Text::CSV

    sudo apt install python-pip                                                   # Install aws cli
    mkdir .aws                                                                    # Create aws credentials folder
    nano .aws/config                                                              # Cut, paste, save from your local system files
    nano .aws/credentials                                                         # Ditto

    aws s3 cp s3://exchange.ryffine/pcd/zipPcd.zip .                              # Download PCD install package
    aws s3 cp s3://exchange.ryffine/pcd/zipPcd.pl  .                              # ditto

    perl zipPcd.pl                                                                # Install PCD

Kill all your terminal and [Geany](https://www.geany.org)  sessions to pick up the installation
changes.

To test [Dita::PCD](https://metacpan.org/pod/Dita::PCD) from the [command line](https://en.wikipedia.org/wiki/Command-line_interface):

    makeWithPerl --run r/z/pleaseChangeDita/test.pcd

which runs the [Dita::PCD](https://metacpan.org/pod/Dita::PCD) against the supplied [Dita](http://docs.oasis-open.org/dita/dita/v1.3/os/part2-tech-content/dita-v1.3-os-part2-tech-content.html) file:

    r/z/pleaseChangeDita/1.dita

to produce:

    r/z/pleaseChangeDita/out/1.dita

and the following run time messages:

    02:59:58 Change d under c under b to D at /home/ubuntu/r/z/pleaseChangeDita/test.pcd line 2
    02:59:58 BBBB  at /home/ubuntu/r/z/pleaseChangeDita/test.pcd line 8
    <b>
      <c>
        <d/>
      </c>
    </b>
    02:59:58 Change B to b at /home/ubuntu/r/z/pleaseChangeDita/test.pcd line 6
    02:59:58 Merge two adjacent b at /home/ubuntu/r/z/pleaseChangeDita/test.pcd line 10

To test from [Geany](https://www.geany.org):

    geany r/z/pleaseChangeDita/test.pcd

Press **F8** for a syntax check. Press **F9** to execute the [Dita::PCD](https://metacpan.org/pod/Dita::PCD) to get
results similar in the message window to those shown above.

The PCD manual is at:
[https://philiprbrenan.github.io/data\_edit\_xml\_edit\_commands.html](https://philiprbrenan.github.io/data_edit_xml_edit_commands.html)
