//
//  ColorTable.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// "Table" of static, named colors and functions to access them. Rather than using Assets.xcassets, we use code because with
/// multiple targets, you have multiple Assets.xcassets files. Maintaining multiple copies of the same data is a no-no. To
/// get around that, we use code to define named colors. It's not as pretty as Xcode's way, but it **is** more robust and
/// maintainable.
enum ColorNames: UInt, CaseIterable
{
    /// Special case handled in code.
    case Clear = 0x010101                           //Special case handled in code.
    /// Special case handled in code.
    case Random = 0x000101                          //Special case handled in code.
    /// Standard red.
    case Red = 0xff0000
    case Green = 0x00ff00
    case Blue = 0x0000ff
    case Cyan = 0x00ffff
    case Magenta = 0xff00ff
    case Yellow = 0xffff00
    case Black = 0x000000
    case White = 0xffffff
    case DarkRed = 0x8b0000
    case Vermillion = 0xe44d2e
    case BloodRed = 0x660000
    case AtomicTangerine = 0xff9966
    case BabyBlue = 0x89cff0
    case BlizzardBlue = 0xace5ee
    case BluePastel = 0xb2cefe
    case BrilliantLavender = 0xf4bbff
    case Champagne = 0xf7e7ce
    case Chartreuse = 0xdfff00
    case Citrine = 0xe4d00a
    case Coral = 0xff7e50
    case CottonCandy = 0xffbcd9
    case Daffodil = 0xffff31
    case DarkGray = 0x606060
    case ReallyDarkGray = 0x303030
    case DarkPastelGreen = 0x03c03c
    case DarkSeaGreen = 0x8fbc8f
    case DeepSkyBlue = 0x00bfff
    case ElectricLime = 0xccff00
    case Flavescent = 0xf7e98e
    case FloralWhite = 0xfffaf0
    case Gold = 0xffd600
    case GrannySmith = 0xa8efa0
    case GreenPastel = 0xbaed91
    case HoneyDew = 0xf0fff0
    case Lavender = 0xe6e6fa
    case LightBlue = 0xadd8e6
    case LightGoldenrodYellow = 0xfafad2
    case Linen = 0xfaf0e6
    case MagicMint = 0xaaf0d1
    case Mauve = 0xb784a7
    case MintCream = 0xf5fffa
    case MistyRose = 0xfee4e1
    case Moccasin = 0xffe4b5
    case Mustard = 0xffdb58
    case OldLace = 0xfdf5e6
    case OrangePastel = 0xf88888
    case PaleCerulean = 0x9BC4E2
    case PaleGoldenrod = 0xeee8aa
    case PaleGray = 0xf0f0f0
    case PalePink = 0xfadadd
    case PapayaWhip = 0xffefd5
    case PastelBrown = 0x836952
    case PastelMagenta = 0xf49ac2
    case PastelPink = 0xffd1dc
    case PastelPurple = 0xb39eb5
    case PastelRed = 0xff6961
    case PastelYellow = 0xfdfd96
    case PeachPuff = 0xffdab9
    case Periwinkle = 0xccccff
    case Pink = 0xffc0cb
    case PinkPastel = 0xfea3aa
    case Pistachio = 0x92c571
    case Platinum = 0xe5e4e2
    case PurplePastel = 0xf2a2eb
    case Saffron = 0xf4c430
    case Sandstorm = 0xecd540
    case Seashell = 0xfff5ee
    case Sunglow = 0xffcc33
    case Sunset = 0xfad6a5
    case TeaRose = 0xf4c2c2
    case Thistle = 0xd8bfd8
    case Tomato = 0xff6246
    case VividTangerine = 0xffa089
    case WildBlueYonder = 0xa2add0
    case YellowPastel = 0xfaf884
    case YellowProcess = 0xffef00
    case WhiteSmoke = 0xf5f5f5
    case BlueJeans = 0x4a89dc
    case Aqua = 0x4fc1e9
    case Mint = 0x48cfad
    case Grass = 0xa0d468
    case Sunflower = 0xffce54
    case Bittersweet = 0xfc6e51
    case Grapefruit = 0xed5565
    case PinkRose = 0xd770ad
    case LightGray = 0xe6e9ed
    case MediumGray = 0x434a54
    //Japanese colors
    case Ikkonzome = 0xF08f90
    case KōbaiIro = 0xDb5a6b
    case SakuraIro = 0xFcc9b9
    case Usubeni = 0xF2666c
    case MomoIro = 0xF47983
    case Nakabeni = 0xC93756
    case Arazome = 0xFfb3a7
    case TokihaIro = 0xF58F84
    case ChōshunIro = 0xB95754
    case EnjiIro = 0x9D2933
    case Jinzamomi = 0xF7665A
    case Umenezumi = 0x97645A
    case Akabeni = 0xC3272B
    case AzukiIro = 0x672422
    case Ebicha = 0x5E2824
    case AkebonoIro = 0xFA7B62
    case Shōjōhi = 0xDC3023
    case KakishibuIro = 0x934337
    case Benitobi = 0x913228
    case Kurotobi = 0x351E1C
    case Terigaki = 0xD34E36
    case Edocha = 0xA13D2D
    case HihadaIro = 0x752E23
    case Tokigaracha = 0xE68364
    case Sohi = 0xE35C38
    case Karacha = 0xB35C44
    case Sōdenkaracha = 0x9B533F
    case Kurikawacha = 0x4C221B
    case Sakuranezumi = 0xAC8181
    case Karakurenai = 0xC91F37
    case Kokiake = 0x7B3B3A
    case Mizugaki = 0xB56C60
    case Suōkō = 0xA24F46
    case Shinshu = 0x8F1D21
    case Ginshu = 0xBC2D29
    case Kiriume = 0x8B352D
    case SangoshuIro = 0xF8674F
    case Shikancha = 0xAB4C3D
    case Benikaba = 0x9D2B22
    case Benihibata = 0x6F3028
    case Benihi = 0xF35336
    case Ake = 0xCF3A24
    case BengaraIro = 0x913225
    case ShishiIro = 0xF9906F
    case AkakōIro = 0xF07F5E
    case Ōtan = 0xFF4E20
    case Enshūcha = 0xCB6649
    case Kabacha = 0xB14A30
    case Suzumecha = 0x8C4736
    case Momoshiocha = 0x542D24
    case Kurumizome = 0x9F7462
    case Kōrozen = 0x592B1F
    case Kokikuchinashi = 0xF57F4F
    case TaishaIro = 0x9F5233
    case Tonocha = 0x985538
    case Sharegaki = 0xFFA26B
    case KanzōIro = 0xFF8936
    case Beniukon = 0xFB8136
    case Kenpōzome = 0x2E211B
    case KohakuIro = 0xCa6924
    case KuchibaIro = 0xFFA565
    case Chōjizome = 0xC66B27
    case Fushizome = 0x8C5939
    case SusutakeIro = 0x593A27
    case ŌdoIro = 0xBE7F51
    case Kigaracha = 0xB7702D
    case KabaIro = 0xB64925
    case Kogecha = 0x351F19
    case Araigaki = 0xEC8254
    case Akashirotsurubami = 0xEC956C
    case SenchaIro = 0x824B35
    case Usugaki = 0xFCA474
    case Umezome = 0xFA9258
    case Chōjicha = 0x8F583C
    case Biwacha = 0xAB6134
    case Usukō = 0xFFA564
    case Kincha = 0xC66B28
    case KitsuneIro = 0x985629
    case KyaraIro = 0x6A432D
    case Shiracha = 0xC48E69
    case Kinsusutake = 0x7D4E2D
    case Kobicha = 0x6B4423
    case Usuki = 0xF7BB7D
    case TamagoIro = 0xFFA631
    case Yamabukicha = 0xCB7E1F
    case NamakabeIro = 0x785E49
    case TōmorokoshiIro = 0xFAA945
    case Kitsurubami = 0xBB8141
    case HanabaIro = 0xFFB94E
    case UkonIro = 0xE69B3A
    case Rikyūshiracha = 0xB0927A
    case AkuIro = 0x7F6B5D
    case Rokōcha = 0x665343
    case NataneyuIro = 0xA17917
    case Uguisucha = 0x5C4827
    case Kariyasu = 0xE2B13C
    case MushikuriIro = 0xD3B17D
    case Hiwacha = 0x957B38
    case UguisuIro = 0x645530
    case YamabukiIro = 0xFFA400
    case Hajizome = 0xE08A1E
    case Kuwazome = 0xC57F2E
    case Kuchinashi = 0xFFB95A
    case Shirotsurubami = 0xCE9F6F
    case Tōō = 0xFFB61E
    case TorinokoIro = 0xE2BE9F
    case Kikuchiba = 0xE29C45
    case Rikyūcha = 0x826B58
    case Higosusutake = 0x7F5D3B
    case Mirucha = 0x4C3D30
    case Kimirucha = 0x896C39
    case Nanohanacha = 0xE3B130
    case Kihada = 0xF3C13A
    case Aokuchiba = 0xAA8736
    case Ominaeshi = 0xD9B611
    case HiwaIro = 0xBDA928
    case Yanagicha = 0x9C8A4D
    case Aikobicha = 0x473F2D
    case Baikōcha = 0x857C55
    case Hiwamoegi = 0x7A942E
    case Urayanagi = 0xBCB58C
    case Yanagizome = 0x8C9E5E
    case Aoni = 0x52593B
    case Aoshiroturubami = 0xBBA46D
    case Rikancha = 0x534A32
    case KokeIro = 0x8B7D3A
    case Sensaicha = 0x3B3429
    case Iwaicha = 0x5E5545
    case Yanagisusutake = 0x4D4B3A
    case Usumoegi = 0x8DB255
    case Moegi = 0x5B8930
    case MatsubaIro = 0x454D32
    case Usuao = 0x8C9C76
    case Yanaginezumi = 0x817B69
    case Sensaimidori = 0x374231
    case Byakuroku = 0xA5BA93
    case Rokushō = 0x407A52
    case Onandocha = 0x3D4035
    case Rikyūnezumi = 0x656255
    case Mushiao = 0x2D4436
    case SeijiIro = 0x819C8B
    case Sabitetsuonando = 0x3A403B
    case Omeshicha = 0x354E4B
    case WakatakeIro = 0x6B9362
    case OitakeIro = 0x5E644F
    case Midori = 0x2A603B
    case Sabiseiji = 0x898A74
    case TokusaIro = 0x3D5D42
    case AotakeIro = 0x006442
    case Birōdo = 0x224634
    case Aimirucha = 0x2E372E
    case Mizuasagi = 0x749F8D
    case Seiheki = 0x3A6960
    case TetsuIro = 0x2B3733
    case Kōrainando = 0x203838
    case Minatonezumi = 0x757D75
    case Testuonando = 0x2B3736
    case Sabiasagi = 0x6A7F7A
    case AsagiIro = 0x48929B
    case Sabionando = 0x455859
    case AiIro = 0x264348
    case Hanaasagi = 0x1D697C
    case MasuhanaIro = 0x4D646C
    case NoshimehanaIro = 0x344D56
    case SoraIro = 0x4D8FAC
    case GunjōIro = 0x5D8CAE
    case KachiIro = 0x181B26
    case KonjōIro = 0x003171
    case Benimidori = 0x78779B
    case Fujinezumi = 0x766980
    case FujiIro = 0x89729E
    case Aonibi = 0x4F4944
    case MizuIro = 0x86ABA5
    case Kamenozoki = 0xC6C2B6
    case ShinbashiIro = 0x006C7F
    case Ainezumi = 0x5C544E
    case OnandoIro = 0x364141
    case ChigusaIro = 0x317589
    case Hanada = 0x044F67
    case Omeshionando = 0x3D4C51
    case Kurotsurubami = 0x252321
    case Kon = 0x192236
    case RuriIro = 0x1F4788
    case Rurikon = 0x1B294B
    case Konkikyō = 0x191F45
    case BenikakehanaIro = 0x5A4F74
    case Futaai = 0x614E6E
    case Fujimurasaki = 0x875F9A
    case ShionIro = 0x976E9A
    case Shikon = 0x2B2028
    case UsuIro = 0xA87CA0
    case SumireIro = 0x5B3256
    case Kurobeni = 0x23191E
    case Benifuji = 0xBB7796
    case Hatobanezumi = 0x755D5B
    case Ebizome = 0x6D2B50
    case Bōtan = 0xA4345D
    case Nisemurasaki = 0x43242A
    case Suō = 0x7E2639
    case Benikeshinezumi = 0x44312E
    case KikyōIro = 0x5D3F6A
    case Metsushi = 0x3F313A
    case Kokimurasaki = 0x3A243B
    case HashitaIro = 0x8D608C
    case Murasaki = 0x4F284B
    case AyameIro = 0x763568
    case Kakitsubata = 0x491E3C
    case Budōnezumi = 0x63424B
    case Umemurasaki = 0x8F4155
    case Murasakitobi = 0x512C31
    case Shironeri = 0xFfddca
    case Ginnezumi = 0x97867c
    case Dobunezumi = 0x4b3c39
    case Binrōjizome = 0x352925
    case Kokushoku = 0x171412
    case Shironezumi = 0xB9a193
    case Sunezumi = 0x6e5f57
    case Aisumicha = 0x393432
    case SumiIro = 0x27221f
    //JNR colors
    case 赤1号 = 0xB2152B
    case 赤2号 = 0x842B32
    case 赤3号 = 0x7A453D
    case 赤7号 = 0x563533
    case 赤11号 = 0xC32829
    case 赤13号 = 0x88474B
    case 赤14号 = 0xC9242F
    case ぶどう色1号 = 0x35271D
    case ぶどう色2号 = 0x413027
    case ぶどう色3号 = 0x58211C
    case とび色2号 = 0x735340
    case 朱色1号 = 0xC16543
    case 朱色3号 = 0xE03625
    case 朱色4号 = 0xB53D27
    case 朱色5号 = 0xCA4F3C
    case 黄1号 = 0xFDBC00
    case 黄4号 = 0xEACD6F
    case 黄5号 = 0xE3B144
    case 黄6号 = 0xF7E19E
    case クリーム1号 = 0xD6BC96
    case クリーム2号 = 0xE0C37B
    case クリーム3号 = 0xE2A665
    case クリーム4号 = 0xCFAC84
    case クリーム9号 = 0xCABEAC
    case クリーム10号 = 0xECE0D1
    case クリーム12号 = 0xE6E1D5
    case 黄かん色 = 0xCA6A1F
    case 黄かっ色1号 = 0xA57C4A
    case 黄かっ色2号 = 0x988054
    case 淡緑1号 = 0x9EAE9C
    case 淡緑3号 = 0x7B9681
    case 淡緑5号 = 0x546C55
    case 淡緑6号 = 0x97BC94
    case 淡緑7号 = 0xBAB8A9
    case 黄緑6号 = 0x7BAB4F
    case 黄緑7号 = 0x57B544
    case 緑1号 = 0x005E54
    case 緑2号 = 0x354F33
    case 緑14号 = 0x246029
    case 緑15号 = 0x2E8B57
    case 灰緑色2号 = 0x6D8881
    case 灰緑色3号 = 0x3B6063
    case 青緑1号 = 0x009786
    case 青緑6号 = 0x003835
    case 青1号 = 0x417A83
    case 青2号 = 0x324C51
    case 青3号 = 0x2A3444
    case 青9号 = 0x52799E
    case 青15号 = 0x234059
    case 青19号 = 0x496779
    case 青20号 = 0x003F6C
    case 青22号 = 0x00859E
    case 青23号 = 0x004F8A
    case 青24号 = 0x00B2E5
    case 青26号 = 0x00acd1
    case 薄茶色4号 = 0xB4A18E
    case 薄茶色5号 = 0xD99574
    case 薄茶色6号 = 0xAEA29B
    case 薄茶色13号 = 0xD1C3B5
    case 薄茶色14号 = 0xDDD2C5
    case 薄茶色15号 = 0x765F4B
    case 薄茶色17号 = 0xA98A68
    case 黒 = 0x2A2A2A
    case ねずみ色1号 = 0x767676
    case 灰色1号 = 0x8F8F8F
    case 灰色8号 = 0xAAAAAA
    case 灰色9号 = 0xC5C5C5
    case 灰色16号 = 0xD3D3D3
    case 白3号 = 0xE7E7E8
    // Dull colors
    case DullRed = 0xa88c8c
    case DullGreen = 0x9aa88c
    case DullCyan = 0x8ca8a8
    case DullMagenta = 0x9a8ca8
    case DullGray = 0xa0a0a0
    case DullYellow = 0xa8a88c
    case DullBrown1 = 0xa6917b
    case DullBrown2 = 0xb09e8b
    case DullBrown3 = 0xc5b7a9
    case DullPink = 0xd5a5b1
    // Other, "standard" colors.
    case Gray = 0x888888
    // Wikipedia colors (subset).
    case PineGreen = 0x01796f
    case Burgundy = 0x900020
    case PrussianBlue = 0x003153
    case Cerulean = 0x007ba7
    case DarkCyan = 0x008B8B
    case Keppel = 0x3ab09e
    case MagentaDye = 0xca1f7b
    case AmaranthPurple = 0xab274f
    case MagentaPantone = 0xd0417e
    case Telemagenta = 0xcf3476
    case MagentaHaze = 0x9f4576
    case YellowNCS = 0xffd300
    case YellowMunsell = 0xefcc00
    case YellowPantone = 0xfedf00
    case CloverLime = 0xfce883
    case MellowYellow = 0xf8de7e
    case CyberYellow = 0xffd301         //the least significant bit of blue is there just to keep the compiler happy
    case BrightYellow = 0xffaa1d
    case SafetyYellow = 0xeed202
    case DarkOrange = 0xff8c00
    case CarrotOrange = 0xed9121
    case PrincetonOrange = 0xee7f2d
    case SpanishOrange = 0xe86100
    case YInMnBlue = 0x2e5090
    // Color picker names.
    case Licorice = 0x000001            //the least significant bit of blue is there just to keep the compiler happy
    case Lead = 0x212121
    case Tungsten = 0x424242
    case Iron = 0x5e5e5e
    case Steel = 0x797979
    case Tin = 0x919191
    case Nickel = 0x929292
    case Aluminum = 0xa9a9a9
    case Magnesium = 0xc0c0c0
    case Silver = 0xd5d5d5
    case Mercury = 0xebebeb
    case Snow = 0xfffffe                //the least significant bit of blue is missing to keep the compiler happy
    case Cayenne = 0x941100
    case Mocha = 0x935100
    case Asparagus = 0x929000
    case Fern = 0x4e8f00
    case Clover = 0x008e00
    case Moss = 0x008f51
    case Teal = 0x009192
    case Ocean = 0x005392
    case Midnight = 0x011892
    case Eggplant = 0x521b92
    case Plum = 0x942092
    case MacMaroon = 0x941651
    case Maraschino = 0xff2600
    case Tangerine = 0xff9300
    case Lemon = 0xfefb00
    case Lime = 0x8df900
    case Spring = 0x00f900
    case SeaFoam = 0x00fa92
    case Turquoise = 0x00fcff
    case MacAqua = 0x0096ff
    case Blueberry = 0x0432ff
    case Grape = 0x9437ff
    case MacMagenta = 0xff40ff
    case Strawberry = 0xff2f92
    case Salmon = 0xff7d78
    case Cantaloupe = 0xffd478
    case Banana = 0xfefc78
    case Honeydew = 0xd4fb78
    case Flora = 0x72fa78
    case Spindrift = 0x72fcd5
    case Ice = 0x73fdff
    case Sky = 0x75d5ff
    case Orchid = 0x7980ff
    case MacLavender = 0xd783ff
    case Bubblegum = 0xff84ff
    case Carnation = 0xff89d8
    case Maroon = 0x800000
}
