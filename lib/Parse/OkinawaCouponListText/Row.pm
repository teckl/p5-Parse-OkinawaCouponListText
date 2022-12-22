package Parse::OkinawaCouponListText::Row;
use strict;
use warnings;
use utf8;

my @COLUMNS = qw/
    number name category address tel url
/;

my @METHODS = (@COLUMNS, qw/
/);

for my $name (@METHODS) {
    my $sub = sub { $_[0]->{columns}{$name} };
    no strict 'refs';
    *{$name} = $sub;
}

sub columns { @COLUMNS }

sub new {
    my($class, %opts) = @_;

    my $columns = {};
    for my $column (@COLUMNS) {
        $columns->{$column} = delete $opts{$column} if defined $opts{$column};
    }

    my $self = bless {
        %opts,
        columns      => $columns,
    }, $class;

    $self;
}


1;
__END__

=encoding utf8

=head1 NAME

Parse::OkinawaCouponListText::Row - Object of Okinawa Coupon Shop

=head1 METHODS

=head2 new

instance method.

=head2 number

沖縄県地域クーポン加盟店リストの番号 を返します。

=head2 name

施設名 を返します。

=head2 category

カテゴリ を返します。

=head2 address

住所 を返します。

=head2 tel

電話番号 を返します。

=head2 url

公式サイトを返します。なければ `なし` が返ります。

=head1 AUTHOR

Shigeki Sugai E<lt>teckl1979 {at} gmail {dot} comE<gt>

=head1 SEE ALSO

L<Parse::OkinawaCouponListText>,
L<https://okinawasaihakkennext.com/coupon.html>
L<https://qiita.com/teckl/items/b8d685be2241d0b393c1>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
