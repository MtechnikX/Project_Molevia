﻿local L = LibStub("AceLocale-3.0"):NewLocale("MacroBank", "koKR", false);
if not L then return end
L["AcceptIcon"] = "적용"
L["AcceptIconDesc"] = "이 아이콘을 적용합니다."
L["Accept new Macro from %s?"] = "%s 의 새 매크로를 받습니까?" -- Needs review
-- L["Auto accepted %d macros."] = "Auto accepted %d macros."
-- L["Auto Accept Macros"] = "Auto Accept Macros"
-- L["Auto Accept Macros Desc"] = "Automatically accept macros sent from other MacroBank users."
L["AutoLoad"] = "자동으로 불러오기"
L["AutoLoadDesc"] = "자동으로 매크로 그룹을 불러오게 설정합니다."
L["AutoOpenMacroBank"] = "MacroBank 자동 열기"
L["AutoOpenMacroBankDesc"] = "매크로 창이 열릴 때 MacroBank 창을 엽니다."
L["CancelDesc"] = "이 메뉴를 닫습니다."
L["Can't find category"] = "카테고리를 찾을 수 없음"
L["Can't load macros in combat"] = "전투시에는 매크로를 불려올 수 없습니다."
L["Category"] = "카테고리"
L["Category?"] = "카테고리?"
L["CategoryDesc"] = [=[선택된 매크로를 위한 카테고리를 설정합니다.
(엔터 입력시 저장)]=]
-- L["Category Name"] = "Category Name"
-- L["Change Category"] = "Change Category"
--[==[ L["Change Category Description"] = [=[Changes the category for these macros.
(Macros in sub-categories will remain)
]=] ]==]
-- L["Char"] = "Char"
L["CharCategory"] = "케릭터 카테고리"
L["CharCategoryDesc"] = "카테고리의 매크로를 케릭터 매크로로 불러오기 위해 선택합니다." -- Needs review
L["CharDesc"] = "케릭터 섹션에서 매크로를 불러옵니다."
-- L["Couldn't create category"] = "Couldn't create category"
L["Create"] = "새로 만들기"
-- L["Create Category"] = "Create Category"
L["CreateDesc"] = "매크로 은행에 새로운 매크로를 만듭니다."
-- L["Creates a new category."] = "Creates a new category."
L["Default"] = "기본값"
L["DefaultCategoryDesc"] = "만들어졌거나 저장된 매크로의 카테고리를 설정합니다."
L["DefaultDescriptionDesc"] = "만들어졌거나 저장된 매크로의 설명을 설정합니다."
L["DefaultNameDesc"] = "만들어졌거나 저장된 매크로의 이름을 설정합니다."
L["Delete"] = "삭제"
L["Delete Char Macros"] = "케릭터 매크로를 삭제합니다."
L["DeleteDesc"] = "매크로 은행에서 선택된 매크로를 삭제합니다."
L["Delete Global Macros"] = "글로벌 매크로를 삭제합니다."
-- L["Delete Macros"] = "Delete Macros"
L["Delete Macro %s?"] = "%s 매크로를 삭제하시겠습니까?"
-- L["Delete macros in %s?"] = "Delete macros in %s?"
L["Delete Macros On AutoLoad Desc"] = "매크로를 자동으로 불러오도록 설정한다면, 불러오기 전 현재 매크로들을 삭제합니다." -- Needs review
-- L["Deletes all subcategories and their macros of this category."] = "Deletes all subcategories and their macros of this category."
-- L["Deletes macros in this category."] = "Deletes macros in this category."
-- L["Delete Subcategories"] = "Delete Subcategories"
-- L["Delete subcategories of %s?"] = "Delete subcategories of %s?"
L["Description"] = "설명"
L["DescriptionDesc"] = [=[이 매크로의 간단한 설명을 설정합니다.
(엔터 입력시 저장)]=]
L["FromMacroBank"] = "<-----"
-- L["Global"] = "Global"
L["GlobalCategory"] = "전역 카테고리"
L["GlobalCategoryDesc"] = "카테고리의 매크로를 전역 매크로로 불러오기 위해 선택합니다." -- Needs review
L["GlobalDesc"] = "글로벌 섹션에서 매크로를 불러옵니다."
L["Guild"] = "길드"
L["Icon"] = "아이콘"
L["IconDesc"] = "선택된 매크로를 위한 아이콘을 설정합니다."
L["Load"] = "복원"
L["LoadCategory"] = "카테고리 불러오기"
-- L["Load Category"] = "Load Category"
L["LoadCategoryDesc"] = "카테고리에서 카테고리나 단일 매크로를 불러옵니다."
L["LoadDesc"] = [=[매크로 은행에 있는 매크로를 복원합니다.
(만약 똑같은 이름이 있는 매크로가 존재한다면 그것을 대신 합니다.)]=]
L["LoadPreMade"] = "매크로 불러오기"
L["LoadPreMadeDesc"] = "PreMadeMacros.lua에서 미리 만들어진 매크로를 불러옵니다."
-- L["Loads the selected category."] = "Loads the selected category."
L["Login Group"] = "로그인 그룹"
L["Login Group Desc"] = "로그인 할 때 매크로들을 불러옵니다."
L["Macro"] = "매크로"
L["MacroBank"] = "MacroBank"
L["MacroBank User"] = "MacroBank 이용자"
L["MacroDefaults"] = "기본 매크로"
L["MacroDefaultsDesc"] = "만들어졌거나 저장된 매크로들을 기본으로 설정합니다." -- Needs review
L["MacroDesc"] = [=[선택된 매크로를 위한 내용을 설정합니다.
(당신이 ESC를 누루거나 편집 상자에서 벗어날때 저장합니다.)]=]
L["MacroOptions"] = "매크로 설정"
-- L["MacroOptionsDesc"] = "Settings for how MacroBank behaves."
L["MacroScrollLine"] = "매크로 목록"
L["MacroScrollLineDesc"] = "편집, 불려오기 또는 삭제를 할 매크로를 선택합니다."
-- L["Must not be empty"] = "Must not be empty"
L["Name"] = "이름"
L["NameDesc"] = [=[선택된 매크로를 위한 이름을 설정합니다.
사용을 위해 새로 불려옵니다.
(엔터 입력시 저장)]=]
L["None"] = "없음"
L["Non-MacroBank User"] = "MacroBank 사용자가 아닙니다."
L["Not enough room to load macro"] = "매크로를 불려올 충분한 방이 없습니다."
L["On Login"] = "로그인 중" -- Needs review
L["On Talent Swap"] = "특성 교체 중" -- Needs review
L["Options"] = "설정"
L["OptionsDesc"] = "옵션창 표시"
-- L["Overwrite Received"] = "Overwrite Received"
-- L["Overwrite Received Desc"] = "Replace macros with the same name, description and icon when receiving macros from someone."
L["Party"] = "파티"
L["Player"] = "플레이어"
L["Pre-Made Macros"] = "미리 만들어진 매크로"
L["Primary Talent Spec Group"] = "주특성 스펙 그룹" -- Needs review
L["Primary Talent Spec Group Desc"] = "주특성으로 전환하면 매크로를 불러옵니다."
L["Raid"] = "레이드"
L["ReceivedCategory"] = "카테고리 받음"
L["ReceivedCategoryDesc"] = "받은 매크로의 카테고리를 설정합니다. (%s을 보낸사람에 대한 변수로 사용)"
L["RememberPosition"] = "위치 기억"
L["RememberPositionDesc"] = "MacroBank 창을 옮겼을 때 위치를 기억합니다."
L["Replace"] = "변경"
L["ReplaceDesc"] = "매크로 은행에 있는 매크로 내용으로 변경합니다."
-- L["ReplaceIconDesc"] = "Replace the icon with the one from MacroBank."
-- L["ReplaceNameDesc"] = "Replace the name with the one from MacroBank."
L["ReplaceOptions"] = "대체 설정"
-- L["ReplaceOptionsDesc"] = "Change how the replace button behaves."
L["ResetAnchor"] = "창 위치 초기화" -- Needs review
L["ResetAnchorDesc"] = "MacroBank 창 기본 위치로 리셋합니다." -- Needs review
L["%s Accepted your macro"] = "%s 가 당신의 매크로를 받았습니다."
L["Save"] = "저장"
L["SaveDesc"] = "매크로 은행에 선택된 매크로를 저장합니다."
L["Secondary Talent Spec Group"] = "부특성 스펙 그룹" -- Needs review
L["Secondary Talent Spec Group Desc"] = "부특성으로 전환하면 매크로를 불러옵니다."
L["Send selected macro to"] = "선택된 매크로 보내기"
L["Sends the currently selected macro to another MacroBank user."] = [=[현재 선택된 매크로를 다른 MacroBank 사용자에게 보냅니다.
현재 사용불가]=] -- Needs review
L["Sends the currently selected macro to another user."] = "현재 선택된 매크로를 다른 유저에게 보냅니다."
L["SendTo"] = "보내기"
-- L["Show Icons"] = "Show Icons"
-- L["Show Icons Desc"] = "Show icons in the macro bank list."
L["SlashCmd1"] = "macrobank"
L["SlashCmd2"] = "mb"
L["%s Rejected your macro"] = "%s 가 당신의 매크로를 거부했습니다."
L["TempCategory"] = "임시 카테고리"
L["TempDescription"] = "임시 설명"
L["TempName"] = "임시 이름"
L["TempReceivedCategory"] = "%s 로부터"
L["ToMacroBank"] = "----->"
-- L["Unable to load macro - no macro name"] = "Unable to load macro - no macro name"
L["UseNameForDescription"] = "설명에 이름 사용하기"
-- L["UseNameForDescriptionDesc"] = "Use the name of the macro as the description instead of the default description for macros being saved."

