
# NAME

Parse::OkinawaCouponListText - おきなわ彩発見NEXT地域クーポン加盟店承認店舗一覧 Parser for https://okinawasaihakkennext.com/coupon.html

# SYNOPSIS

    use Text::CSV_XS;
    use Parse::OkinawaCouponListText;

    my $csv = Text::CSV_XS->new({binary => 1});
    my $parser = Parse::OkinawaCouponListText->new( file => './PDF_TO_TEXT_OKINAWA_COUPON_LIST_20221220.txt' );
    while (my $obj = $parser->fetch_obj) {
        $csv->combine($obj->number, $obj->name, $obj->category, $obj->address, $obj->tel, $obj->url);
        say $csv->string;
    }

# DESCRIPTION

Parse::OkinawaCouponListText is a feel good parser that parses text files based on the PDF data of the list of approved local coupon merchant stores provided by Okinawa Prefecture.

Parse::OkinawaCouponListText は、沖縄県が提供しているおきなわ彩発見NEXTの地域クーポン加盟店承認店舗一覧のPDFデータをベースにしたテキストファイルを良い感じにパースしてくれるパーサです。

# METHODS

## new

create to parser instance.

read from file path.

    my $parser = Parse::OkinawaCouponListText->new(
        file => './PDF_TO_TEXT_OKINAWA_COUPON_LIST_20221220.txt',
    );

read from file handle.

    my $parser = Parse::OkinawaCouponListText->new(
        fh => $pdf_to_text_coupon_list_fh,
    );

## fetch\_obj

get one line object from OKINAWA_COUPON_LIST.txt

    while (my $obj = $parser->fetch_obj) {
      say $obj->zip;
    }

get_line で取得した行を、 [Parse::OkinawaCouponListText::Row](https://github.com/teckl/p5-Parse-OkinawaCouponListText/blob/main/lib/Parse/OkinawaCouponListText/Row.pm) でオブジェクト化したオブジェクトを返します。

# SEE ALSO

[Parse::OkinawaCouponListText::Row](https://github.com/teckl/p5-Parse-OkinawaCouponListText/blob/main/lib/Parse/OkinawaCouponListText/Row.pm),
[https://okinawasaihakkennext.com/coupon.html](https://okinawasaihakkennext.com/coupon.html)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
