package Parse::OkinawaCouponListText;
use strict;
use warnings;
use utf8;
our $VERSION = '0.01';

use Data::Dumper;
use Parse::OkinawaCouponListText::Row;

sub new {
    my($class, %opts) = @_;

    my $self = bless {
        %opts,
    }, $class;

    if ( ! $self->{fh} && $self->{file} && -f $self->{file}) {
        open $self->{fh}, '<:utf8', $self->{file};
    }

    $self;
}

sub fetch_obj {
    my($self, ) = @_;

    my $shop;
    # 前回の宇宙の法則乱れを回収する
    if ($self->{_next_number}) {
        $shop->{number} = delete $self->{_next_number};
    }
    if ($self->{_next_name}) {
        $shop->{name} = delete $self->{_next_name};
    }

    while (1) {
        $shop = $self->get_line(\$shop);
        last unless $shop;
        last if ($shop->{_found_separator_between_shop});
    }
    return unless $shop;
    delete $shop->{_found_separator_between_shop};
    my @names = Parse::OkinawaCouponListText::Row->columns;
    my %columns;
    for my $key (keys %$shop) {
        $columns{$key} = $shop->{$key};
    }

    Parse::OkinawaCouponListText::Row->new(
        %columns,
    );
}

sub _get_line {
    my($self, ) = @_;

    my $fh = $self->{fh};
    my $line = <$fh>;
    return unless $line;
    $line =~ s/\r\n$//;

    my @row = map {
        my $data = $_;
        $data =~ s/^"//;
        $data =~ s/"$//;
        $data;
    } split ' ', $line;

    \@row;
}

sub get_line {
    my($self, $shop) = @_;

    my $row = $self->_get_line;
    return unless $row;
    delete $$shop->{number_to_name}; # 基本的に番号と店名はほぼ同一行に存在する
    for my $val (@$row) {
        if ($val =~ /^(\d+)$/) {
            if ($$shop->{number}) {
                # 宇宙の法則の乱れ、別店舗行混入時
                $self->{_next_number} = $1;  # 次回のために一時保存
                $$shop->{number_to_name} = 1;
            } else {
                $$shop->{number} = $1;
                $$shop->{number_to_name} = 1;
            }
        } elsif ($val =~ /^(沖縄県(.+))/) {
            $$shop->{address} = $1;
            $$shop->{address_next} = 1;
        } elsif ($val =~ m{^(\d[-0-9]{10,12})$}) { # 電話番号の入力ミスも存在しているので10桁〜12桁がありえる
            $$shop->{tel} = $1;
            delete $$shop->{address_next};
        } elsif ($val =~ m{^(https?://[^\s]+|なし)$}) {
            $$shop->{url} = $1;
            $$shop->{_found_separator_between_shop} = 1; # 店舗の区切り
        } elsif ($val =~ /(.+)/) {
            if ($$shop->{number_to_name} && $self->{_next_number}) {
                # 宇宙の法則の乱れ、別店舗行混入時
                $self->{_next_name} = join(' ', $self->{_next_name} ? $self->{_next_name} : '', $1);  # 次回のために一時保存
            } elsif ($$shop->{number_to_name}) {
                $$shop->{name} = join(' ', $$shop->{name} ? $$shop->{name} : '', $1);
            } elsif ($$shop->{address_next}) {
                $$shop->{address} = join(' ', $$shop->{address}, $1);
            } else {
                $$shop->{category} = $1;
            }
        }
    }

    $$shop;
}

1;
__END__

=encoding utf8

=head1 NAME

Parse::OkinawaCouponListText - おきなわ彩発見NEXT地域クーポン加盟店承認店舗一覧 Parser for https://okinawasaihakkennext.com/coupon.html

=head1 SYNOPSIS

    use Text::CSV_XS;
    use Parse::OkinawaCouponListText;

    my $csv = Text::CSV_XS->new({binary => 1});
    my $parser = Parse::OkinawaCouponListText->new( file => './PDF_TO_TEXT_OKINAWA_COUPON_LIST_20221220.txt' );
    while (my $obj = $parser->fetch_obj) {
        $csv->combine($obj->number, $obj->name, $obj->category, $obj->address, $obj->tel, $obj->url);
        say $csv->string;
    }

=head1 DESCRIPTION

Parse::OkinawaCouponListText is a feel good parser that parses text files based on the PDF data of the list of approved local coupon merchant stores provided by Okinawa Prefecture.

Parse::OkinawaCouponListText は、沖縄県が提供しているおきなわ彩発見NEXTの地域クーポン加盟店承認店舗一覧のPDFデータをベースにしたテキストファイルを良い感じにパースしてくれるパーサです。

=head1 METHODS

=head2 new

create to parser instance.

read from file path.

    my $parser = Parse::OkinawaCouponListText->new(
        file => './PDF_TO_TEXT_OKINAWA_COUPON_LIST_20221220.txt',
    );

read from file handle.

    my $parser = Parse::OkinawaCouponListText->new(
        fh => $pdf_to_text_coupon_list_fh,
    );

=head2 fetch_obj

get one line object from OKINAWA_COUPON_LIST.txt

    while (my $obj = $parser->fetch_obj) {
        say $obj->zip;
    }

get_line で取得した行を、 L<Parse::OkinawaCouponListText::Row> でオブジェクト化したオブジェクトを返します。

=head1 AUTHOR

Shigeki Sugai E<lt>teckl1979 {at} gmail {dot} comE<gt>

=head1 SEE ALSO

L<Parse::OkinawaCouponListText::Row>,
L<https://okinawasaihakkennext.com/coupon.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
