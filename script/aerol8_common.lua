--=============================================================================
-- Aerol-8 / "mech" custom set -- shared library
--
-- Every card in the set loads this with:  Duel.LoadScript("aerol8_common.lua")
--
-- Setcodes 0xa50-0xa56 were verified unused across all 787 setcodes in every
-- shipped database, and clean across all 16 subtype nibbles, so a "mech"
-- search can never collide with an official card.
--
-- The set uses flat setcodes rather than the Genex-style sub-archetype nibble,
-- because that nibble is matched with a bitwise AND and therefore only affords
-- four sub-archetypes per base. This set has five families.
--=============================================================================

SET_MECH          = 0xa50 --umbrella: every "...mech" name
SET_HUMMECH       = 0xa51
SET_DRAGONFLYMECH = 0xa52
SET_BUTTERFLYMECH = 0xa53
SET_MOTHMECH      = 0xa54
SET_ULTIMECH      = 0xa55
SET_AEROL         = 0xa56

--Cards referenced by name from other scripts in the set.
CARD_BIONIC_LAB_AEROL8   = 900000601
CARD_ULTIMECH_LAB_AEROL8 = 900000602
CARD_AEROL8_ACCEL        = 900000603

Aerol8=Aerol8 or {}

--"Level 1/Rank 1/Link 1" -- the predicate the whole set is built on.
--IsLevel is false for Xyz and Link monsters, IsRank only true for Xyz, and
--IsLink only true for Link, so exactly one branch can match a given monster.
function Aerol8.IsTier1(c)
	return c:IsLevel(1) or c:IsRank(1) or c:IsLink(1)
end

--Field-presence form. Level/Rank/Link checks on monsters you "control" follow
--the shipped convention of requiring face-up (cf. Spright Jet, 13533678).
function Aerol8.IsTier1Faceup(c)
	return c:IsFaceup() and Aerol8.IsTier1(c)
end

--Target filter for EFFECT_CANNOT_SPECIAL_SUMMON, which passes extra summon
--context arguments after the card.
function Aerol8.NonTier1Limit(e,c,sump,sumtype,sumpos,targetp)
	return not Aerol8.IsTier1(c)
end

--"You cannot Special Summon monsters, except Level 1/Rank 1/Link 1 monsters,
--for the rest of this turn."
--
--Registered to the player rather than the card so it survives the source
--leaving the field. Mirrors Spright Starter (15443125), which applies the
--same lock one Level up.
function Aerol8.LockSpecialSummon(c,tp,desc)
	local e=Effect.CreateEffect(c)
	if desc then e:SetDescription(desc) end
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e:SetTargetRange(1,0)
	e:SetTarget(Aerol8.NonTier1Limit)
	e:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e,tp)
end

--Summon types that count as "Summoned using this card as material".
AEROL8_MATERIAL_REASONS = REASON_FUSION|REASON_SYNCHRO|REASON_XYZ|REASON_LINK

--Condition for the EVENT_BE_MATERIAL inheritance effects: this card was just
--used as material for a WIND monster's Summon. Structure follows
--Ukanomitsune-no-Tamayura (93413793), which gates on REASON_SYNCHRO alone.
function Aerol8.WindInheritCon(e,tp,eg,ep,ev,re,r,rp)
	if r&AEROL8_MATERIAL_REASONS==0 then return false end
	local rc=e:GetHandler():GetReasonCard()
	return rc~=nil and rc:IsAttribute(ATTRIBUTE_WIND)
end

function Aerol8.Tier1MachineFilter(e,c)
	return c:IsRace(RACE_MACHINE) and Aerol8.IsTier1(c)
end

--Every granted effect carries this. An inherited effect belongs to the monster
--that received it, so negating that monster has to switch the grant off -- and
--the grant has to come back when the negation ends. A condition is re-checked
--continuously, so it restores on its own; a RESET_DISABLE would remove the
--effect permanently and never come back.
function Aerol8.HostNotNegated(e)
	return not e:GetHandler():IsDisabled()
end

--Grant the inheriting monster: "All Level 1/Rank 1/Link 1 Machine monsters you
--control are also treated as <race> monsters."
--
--NOTE: only two shipped cards use EFFECT_ADD_RACE at all, and both are
--EFFECT_TYPE_SINGLE, so a field-scoped grant is untrodden ground. ocgcore's
--filter_effect collects field effects for get_race(), so this should hold, but
--it wants confirming on a real board.
function Aerol8.GrantRaceToTier1Machines(rc,race,desc)
	--Give it TYPE_EFFECT first if it lacks it, as Ukanomitsune does.
	if not rc:IsType(TYPE_EFFECT) then
		local e0=Effect.CreateEffect(rc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_ADD_TYPE)
		e0:SetValue(TYPE_EFFECT)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e0,true)
	end
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(desc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(Aerol8.Tier1MachineFilter)
	e1:SetCondition(Aerol8.HostNotNegated)
	e1:SetValue(race)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end

function Aerol8.IsNotTier1(c)
	return not Aerol8.IsTier1(c)
end

--"If you control no monsters, or all monsters you control are Level 1/Rank 1/
--Link 1 monsters" -- the shared Special Summon condition of the extenders.
--The empty board is covered vacuously. Face-down monsters count: this gates a
--restriction, so it reads strictly rather than requiring face-up.
function Aerol8.BoardIsAllTier1(tp)
	return not Duel.IsExistingMatchingCard(Aerol8.IsNotTier1,tp,LOCATION_MZONE,0,1,nil)
end

--"Hummech", "Dragonflymech" or "Butterflymech" -- the trio named explicitly by
--Bionic Lab Aerol-8 and others.
--
--Card.IsSetCard takes ONE setcode followed by optional summon context
--(lc, sumtype, tp). Passing several setcodes as varargs does not error, it
--silently reinterprets them as context -- so the codes must be tested apart.
function Aerol8.IsCoreFamily(c)
	return c:IsSetCard(SET_HUMMECH) or c:IsSetCard(SET_DRAGONFLYMECH)
		or c:IsSetCard(SET_BUTTERFLYMECH)
end

--Condition for the Ryea/Immobilizer inheritance: this card was used as
--material for a WIND Fusion/Synchro/Xyz/Link monster *from the field*.
function Aerol8.FieldWindInheritCon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if r&AEROL8_MATERIAL_REASONS==0 then return false end
	if not c:IsPreviousLocation(LOCATION_MZONE) then return false end
	local rc=c:GetReasonCard()
	return rc~=nil and rc:IsAttribute(ATTRIBUTE_WIND)
		and rc:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end

--Turn trackers used by the Ultimech cards and Telethia.
--
--These were built on Duel.AddCustomActivityCounter(ACTIVITY_CHAIN) and were
--WRONG: the filter's polarity is not what it looks like, and with a filter of
--"not IsMonsterEffect()" per counter, activating any two different card types
--pushed all three counters above zero -- so "3 different types" passed on two.
--
--Tracked directly instead. One global EVENT_CHAINING watcher sets one flag per
--card type, so the semantics are ours and there is nothing to misread.
AEROL8_FLAG_MONSTER_ACT  = 900000901
AEROL8_FLAG_SPELL_ACT    = 900000902
AEROL8_FLAG_TRAP_ACT     = 900000903
AEROL8_FLAG_DECK_TO_HAND = 900000904
--Bionic Lab's "only once per chain" marker. It needs a code of its own: that
--card already spends its passcode as the count code of SetCountLimit(2,id),
--and reusing the same value for a player flag effect collides with the
--engine's own bookkeeping for that limit.
AEROL8_FLAG_BIONIC_CHAIN = 900000905

function Aerol8.InstallTrackers()
	if Aerol8.trackers_installed then return end
	Aerol8.trackers_installed=true
	--"an effect of card type X has been activated this turn"
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetOperation(Aerol8.TrackActivation)
	Duel.RegisterEffect(ge1,0)
	--"has added a card from the Deck to the hand by a card effect this turn"
	local ge2=Effect.GlobalEffect()
	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge2:SetCode(EVENT_TO_HAND)
	ge2:SetOperation(Aerol8.TrackDeckToHand)
	Duel.RegisterEffect(ge2,0)
end

--Flags live on player 0 purely as a duel-wide marker: the printed text does not
--say whose effects count, so either player's activation sets them.
function Aerol8.TrackActivation(e,tp,eg,ep,ev,re,r,rp)
	local flag
	if re:IsMonsterEffect() then flag=AEROL8_FLAG_MONSTER_ACT
	elseif re:IsSpellEffect() then flag=AEROL8_FLAG_SPELL_ACT
	elseif re:IsTrapEffect() then flag=AEROL8_FLAG_TRAP_ACT end
	if flag and Duel.GetFlagEffect(0,flag)==0 then
		Duel.RegisterFlagEffect(0,flag,RESET_PHASE|PHASE_END,0,1)
	end
end

function Aerol8.TrackDeckToHand(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT==0 then return end
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_DECK) then
			Duel.RegisterFlagEffect(tc:GetPreviousControler(),AEROL8_FLAG_DECK_TO_HAND,
				RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function Aerol8.HasAddedFromDeck(player)
	return Duel.GetFlagEffect(player,AEROL8_FLAG_DECK_TO_HAND)>0
end

function Aerol8.TypeActivated(flag)
	return Duel.GetFlagEffect(0,flag)>0
end
function Aerol8.MonsterEffectActivated()
	return Aerol8.TypeActivated(AEROL8_FLAG_MONSTER_ACT)
end
--"3 effects of different card types (Monster, Spell, Trap) have been activated
--this turn" -- all three required, one flag each, so two types can never pass.
function Aerol8.ThreeCardTypesActivated()
	return Aerol8.TypeActivated(AEROL8_FLAG_MONSTER_ACT)
		and Aerol8.TypeActivated(AEROL8_FLAG_SPELL_ACT)
		and Aerol8.TypeActivated(AEROL8_FLAG_TRAP_ACT)
end

--Shared "discard or Special Summon this card (from your hand)" tail used by
--Ryea, Immobilizer, Ein, Rheanita and Techtoneas. Returns true if it resolved.
--desc is a table: {discard=<stringid>, summon=<stringid>}. Named rather than
--positional on purpose -- the cards word this clause in both orders ("either
--discard or Special Summon", "either Special Summon or discard"), and passing
--two bare string ids invites labelling the menu backwards.
function Aerol8.DiscardOrSummon(e,tp,desc)
	local desc_discard,desc_summon=desc.discard,desc.summon
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_HAND) then return false end
	local can_sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local can_dis=c:IsAbleToGrave()
	if can_sp and can_dis then
		if Duel.SelectOption(tp,desc_discard,desc_summon)==0 then
			return Duel.SendtoGrave(c,REASON_EFFECT|REASON_DISCARD)>0
		end
		return Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
	elseif can_sp then
		return Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
	elseif can_dis then
		return Duel.SendtoGrave(c,REASON_EFFECT|REASON_DISCARD)>0
	end
	return false
end

--Dragonflymech Carrier's contact-fusion pool and consumption. Kept here rather
--than in the card so Bionic Lab Aerol-8's Fusion branch can drive the same
--routine -- the engine has no IsFusionSummonable to do it generically.
function Aerol8.CarrierMaterialFilter(c)
	return Aerol8.IsTier1(c) and c:IsRace(RACE_WINGEDBEAST|RACE_INSECT)
		and c:IsAbleToDeckOrExtraAsCost()
end
--"among cards you control, in your GY or banished" -- your side only.
function Aerol8.CarrierMaterials(tp)
	return Duel.GetMatchingGroup(Aerol8.CarrierMaterialFilter,tp,
		LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
--Main-deck materials go back to the Deck, Extra Deck ones to the Extra Deck;
--SendtoDeck routes each by its own origin.
function Aerol8.CarrierConsume(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

--Is this card's effect currently granted Quick Effect speed?
--
--Both granting cards register a player-targeted flag keyed to their own
--passcode, exactly as Orcustrated Babel (90351981) does; a monster reads this
--to decide which of its two cloned registrations is live. Their scopes differ,
--so the card itself has to be checked against each:
--
--  Bionic Lab Aerol-8 -- "Hummech"/"Dragonflymech"/"Butterflymech" monsters
--  Aerol-8 Accel      -- Level 1/Rank 1/Link 1 "mech" monsters
function Aerol8.HasQuickGrant(c,tp)
	--Aerol-8 Accel says "Level 1/Rank 1/Link 1 'mech' monsters YOU CONTROL",
	--so the Monster Zone requirement is enforced literally: a card activating
	--out of the hand does not qualify. No monster in the set has a field-based
	--ignition effect yet, so this grant currently reaches nothing -- that is
	--intended, it is groundwork for later cards that do.
	if Duel.IsPlayerAffectedByEffect(tp,CARD_AEROL8_ACCEL)~=nil
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and Aerol8.IsTier1(c) and c:IsSetCard(SET_MECH) then
		return true
	end
	--Bionic Lab Aerol-8 says "Your ... monster effects" with no location
	--clause, so it does reach the hand.
	return Duel.IsPlayerAffectedByEffect(tp,CARD_BIONIC_LAB_AEROL8)~=nil
		and Aerol8.IsCoreFamily(c)
end
