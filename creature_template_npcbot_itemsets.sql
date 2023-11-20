DROP TABLE IF EXISTS `creature_template_npcbot_itemsets`;
CREATE TABLE `creature_template_npcbot_itemsets` (
  `id` int NOT NULL,
  `level` int NOT NULL COMMENT 'In increments of 5',
  `class` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `spec` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `rarity` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `head` int DEFAULT NULL,
  `neck` int DEFAULT NULL,
  `shoulders` int DEFAULT NULL,
  `back` int DEFAULT NULL,
  `chest` int DEFAULT NULL,
  `wrists` int DEFAULT NULL,
  `hands` int DEFAULT NULL,
  `waist` int DEFAULT NULL,
  `legs` int DEFAULT NULL,
  `feet` int DEFAULT NULL,
  `ring1` int DEFAULT NULL,
  `ring2` int DEFAULT NULL,
  `trinket1` int DEFAULT NULL,
  `trinket2` int DEFAULT NULL,
  `weapon1` int DEFAULT NULL,
  `weapon2` int DEFAULT NULL,
  `weapon3` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `creature_template_npcbot_itemsets` (`id`, `level`, `class`, `spec`, `rarity`, `head`, `neck`, `shoulders`, `back`, `chest`, `wrists`, `hands`, `waist`, `legs`, `feet`, `ring1`, `ring2`, `trinket1`, `trinket2`, `weapon1`, `weapon2`, `weapon3`) VALUES
(1, 80, 'druid', 'balance', 'rare', 37180, 43285, 37368, 37799, 37236, 37634, 37261, 38616, 37616, 37640, 37371, 37732, 37660, 37657, 37384, NULL, 42575);


ALTER TABLE `creature_template_npcbot_itemsets`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `creature_template_npcbot_itemsets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;