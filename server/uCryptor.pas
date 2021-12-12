unit uCryptor;

interface

const
	PosX = 113; // Original 127

	function RetiraStr(Caract: String):byte;
	function Cript(Texto: string):string;
	function DesCript(Texto: string):string;

implementation

//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

function RetiraStr(Caract: String):byte;
begin
		if Caract = #32 then  result := 32;
		if Caract = #33 then  result := 33;
		if Caract = #34 then  result := 34;
		if Caract = #35 then  result := 35;
		if Caract = #36 then  result := 36;
		if Caract = #37 then  result := 37;
		if Caract = #38 then  result := 38;
		if Caract = #39 then  result := 39;
		if Caract = #40 then  result := 40;
		if Caract = #41 then  result := 41;
		if Caract = #42 then  result := 42;
		if Caract = #43 then  result := 43;
		if Caract = #44 then  result := 44;
		if Caract = #45 then  result := 45;
		if Caract = #46 then  result := 46;
		if Caract = #47 then  result := 47;
		if Caract = #48 then  result := 48;
		if Caract = #49 then  result := 49;
		if Caract = #50 then  result := 50;
		if Caract = #51 then  result := 51;
		if Caract = #52 then  result := 52;
		if Caract = #53 then  result := 53;
		if Caract = #54 then  result := 54;
		if Caract = #55 then  result := 55;
		if Caract = #56 then  result := 56;
		if Caract = #57 then  result := 57;
		if Caract = #58 then  result := 58;
		if Caract = #59 then  result := 59;
		if Caract = #60 then  result := 60;
		if Caract = #61 then  result := 61;
		if Caract = #62 then  result := 62;
		if Caract = #63 then  result := 63;
		if Caract = #64 then  result := 64;
		if Caract = #65 then  result := 65;
		if Caract = #66 then  result := 66;
		if Caract = #67 then  result := 67;
		if Caract = #68 then  result := 68;
		if Caract = #69 then  result := 69;
		if Caract = #70 then  result := 70;
		if Caract = #71 then  result := 71;
		if Caract = #72 then  result := 72;
		if Caract = #73 then  result := 73;
		if Caract = #74 then  result := 74;
		if Caract = #75 then  result := 75;
		if Caract = #76 then  result := 76;
		if Caract = #77 then  result := 77;
		if Caract = #78 then  result := 78;
		if Caract = #79 then  result := 79;
		if Caract = #80 then  result := 80;
		if Caract = #81 then  result := 81;
		if Caract = #82 then  result := 82;
		if Caract = #83 then  result := 83;
		if Caract = #84 then  result := 84;
		if Caract = #85 then  result := 85;
		if Caract = #86 then  result := 86;
		if Caract = #87 then  result := 87;
		if Caract = #88 then  result := 88;
		if Caract = #89 then  result := 89;
		if Caract = #90 then  result := 90;
		if Caract = #91 then  result := 91;
		if Caract = #92 then  result := 92;
		if Caract = #93 then  result := 93;
		if Caract = #94 then  result := 94;
		if Caract = #95 then  result := 95;
		if Caract = #96 then  result := 96;
		if Caract = #97 then  result := 97;
		if Caract = #98 then  result := 98;
		if Caract = #99 then  result := 99;
		if Caract = #100 then  result := 100;
		if Caract = #101 then  result := 101;
		if Caract = #102 then  result := 102;
		if Caract = #103 then  result := 103;
		if Caract = #104 then  result := 104;
		if Caract = #105 then  result := 105;
		if Caract = #106 then  result := 106;
		if Caract = #107 then  result := 107;
		if Caract = #108 then  result := 108;
		if Caract = #109 then  result := 109;
		if Caract = #110 then  result := 110;
		if Caract = #111 then  result := 111;
		if Caract = #112 then  result := 112;
		if Caract = #113 then  result := 113;
		if Caract = #114 then  result := 114;
		if Caract = #115 then  result := 115;
		if Caract = #116 then  result := 116;
		if Caract = #117 then  result := 117;
		if Caract = #118 then  result := 118;
		if Caract = #119 then  result := 119;
		if Caract = #120 then  result := 120;
		if Caract = #121 then  result := 121;
		if Caract = #122 then  result := 122;
		if Caract = #123 then  result := 123;
		if Caract = #124 then  result := 124;
		if Caract = #125 then  result := 125;
		if Caract = #126 then  result := 126;
//		if Caract = '' then  result := 127;
		if Caract = #128 then  result := 128;
//		if Caract = '' then  result := 129;
		if Caract = #130 then  result := 130;
		if Caract = #131 then  result := 131;
		if Caract = #132 then  result := 132;
		if Caract = #133 then  result := 133;
		if Caract = #134 then  result := 134;
		if Caract = #135 then  result := 135;
		if Caract = #136 then  result := 136;
		if Caract = #137 then  result := 137;
		if Caract = #138 then  result := 138;
		if Caract = #139 then  result := 139;
		if Caract = #140 then  result := 140;
//		if Caract = '' then  result := 141;
//		if Caract = '' then  result := 142;
//		if Caract = '' then  result := 143;
//		if Caract = '' then  result := 144;
		if Caract = #145 then  result := 145;
		if Caract = #146 then  result := 146;
		if Caract = #147 then  result := 147;
		if Caract = #148 then  result := 148;
		if Caract = #149 then  result := 149;
		if Caract = #150 then  result := 150;
		if Caract = #151 then  result := 151;
		if Caract = #152 then  result := 152;
		if Caract = #153 then  result := 153;
		if Caract = #154 then  result := 154;
		if Caract = #155 then  result := 155;
		if Caract = #156 then  result := 156;
//		if Caract = '' then  result := 157;
//		if Caract = '' then  result := 158;
		if Caract = #159 then  result := 159;
		if Caract = #160 then  result := 160;
		if Caract = #161 then  result := 161;
		if Caract = #162 then  result := 162;
		if Caract = #163 then  result := 163;
		if Caract = #164 then  result := 164;
		if Caract = #165 then  result := 165;
		if Caract = #166 then  result := 166;
		if Caract = #167 then  result := 167;
		if Caract = #168 then  result := 168;
		if Caract = #169 then  result := 169;
		if Caract = #170 then  result := 170;
		if Caract = #171 then  result := 171;
		if Caract = #172 then  result := 172;
		if Caract = #173 then  result := 173;
		if Caract = #174 then  result := 174;
		if Caract = #175 then  result := 175;
		if Caract = #176 then  result := 176;
		if Caract = #177 then  result := 177;
		if Caract = #178 then  result := 178;
		if Caract = #179 then  result := 179;
		if Caract = #180 then  result := 180;
		if Caract = #181 then  result := 181;
		if Caract = #182 then  result := 182;
		if Caract = #183 then  result := 183;
		if Caract = #184 then  result := 184;
		if Caract = #185 then  result := 185;
		if Caract = #186 then  result := 186;
		if Caract = #187 then  result := 187;
		if Caract = #188 then  result := 188;
		if Caract = #189 then  result := 189;
		if Caract = #190 then  result := 190;
		if Caract = #191 then  result := 191;
		if Caract = #192 then  result := 192;
		if Caract = #193 then  result := 193;
		if Caract = #194 then  result := 194;
		if Caract = #195 then  result := 195;
		if Caract = #196 then  result := 196;
		if Caract = #197 then  result := 197;
		if Caract = #198 then  result := 198;
		if Caract = #199 then  result := 199;
		if Caract = #200 then  result := 200;
		if Caract = #201 then  result := 201;
		if Caract = #202 then  result := 202;
		if Caract = #203 then  result := 203;
		if Caract = #204 then  result := 204;
		if Caract = #205 then  result := 205;
		if Caract = #206 then  result := 206;
		if Caract = #207 then  result := 207;
		if Caract = #208 then  result := 208;
		if Caract = #209 then  result := 209;
		if Caract = #210 then  result := 210;
		if Caract = #211 then  result := 211;
		if Caract = #212 then  result := 212;
		if Caract = #213 then  result := 213;
		if Caract = #214 then  result := 214;
		if Caract = #215 then  result := 215;
		if Caract = #216 then  result := 216;
		if Caract = #217 then  result := 217;
		if Caract = #218 then  result := 218;
		if Caract = #219 then  result := 219;
		if Caract = #220 then  result := 220;
		if Caract = #221 then  result := 221;
		if Caract = #222 then  result := 222;
		if Caract = #223 then  result := 223;
		if Caract = #224 then  result := 224;
		if Caract = #225 then  result := 225;
		if Caract = #226 then  result := 226;
		if Caract = #227 then  result := 227;
		if Caract = #228 then  result := 228;
		if Caract = #229 then  result := 229;
		if Caract = #230 then  result := 230;
		if Caract = #231 then  result := 231;
		if Caract = #232 then  result := 232;
		if Caract = #233 then  result := 233;
		if Caract = #234 then  result := 234;
		if Caract = #235 then  result := 235;
		if Caract = #236 then  result := 236;
		if Caract = #237 then  result := 237;
		if Caract = #238 then  result := 238;
		if Caract = #239 then  result := 239;
		if Caract = #240 then  result := 240;
		if Caract = #241 then  result := 241;
		if Caract = #242 then  result := 242;
		if Caract = #243 then  result := 243;
		if Caract = #244 then  result := 244;
		if Caract = #245 then  result := 245;
		if Caract = #246 then  result := 246;
		if Caract = #247 then  result := 247;
		if Caract = #248 then  result := 248;
		if Caract = #249 then  result := 249;
		if Caract = #250 then  result := 250;
		if Caract = #251 then  result := 251;
		if Caract = #252 then  result := 252;
		if Caract = #253 then  result := 253;
		if Caract = #254 then  result := 254;
		if Caract = #255 then  result := 255;
end;

//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

function Cript(Texto: string):string;
var
	StrVal, StrChar: String;
	ContChar, IntResult, Nr_Max: Integer;
begin
	Nr_Max := length(Texto);
	StrVal := '';
	for ContChar := 1 to Nr_Max do
	begin
		StrChar   := Copy(Texto, ContChar, 1);
    if (StrChar <> 'ó') then
    begin
      IntResult := RetiraStr(StrChar);
      if IntResult = 44 then IntResult := 45 else
      if IntResult = 45 then IntResult := 44 else

      if IntResult <= 143 then // Original '127'
      begin
        if odd(IntResult) then
        begin  //Impares
          IntResult := (intResult - 1) + PosX;
        end
        else
        begin  //Pares
          IntResult := (IntResult + 1) + PosX;
        end;
      end
      else
      begin
        if odd(IntResult) then
        begin  //Impares
          IntResult := (intResult - 1) - PosX;
        end
        else
        begin  //Pares
          IntResult := (IntResult + 1) - PosX;
        end;
      end;
      StrVal := StrVal + chr(IntResult);
    end
    else
      StrVal := StrVal + StrChar;
	end;
	RESULT := StrVal;
end;

//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

function DesCript(Texto: string):string;

var
	StrVal, StrChar: String;
	ContChar, IntResult, Nr_Max: Integer;

begin
	Nr_Max := length(Texto);
	StrVal := '';
	for ContChar := 1 to Nr_Max do
	begin
		StrChar   := Copy(Texto, ContChar, 1);
    if (StrChar <> 'ó') then
    begin
      IntResult := RetiraStr(StrChar);
      if IntResult = 44 then IntResult := 45 else
      if IntResult = 45 then IntResult := 44 else
      if IntResult >= 143 then // Original '127'
      begin
        if odd(IntResult) then
        begin // Pares
          IntResult := (IntResult + 1) - PosX;
        end
        else
        begin // Ímpares
          IntResult := (IntResult - 1) - PosX;
        end;
      end
      else  // 32 a 142
      begin
        if odd(IntResult) then
        begin // Pares
          IntResult := (IntResult + 1) + PosX;
        end
        else
        begin // Ímpares
          IntResult := (IntResult - 1) + PosX;
        end;
      end;
      StrVal := StrVal + chr(IntResult);
    end
    else
      StrVal := StrVal + StrChar;
	end;
	RESULT := StrVal;
end;

//+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+//

end.
