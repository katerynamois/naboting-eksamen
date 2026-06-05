-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Vært: localhost:3306
-- Genereringstid: 17. 04 2026 kl. 09:27:05
-- Serverversion: 5.7.24
-- PHP-version: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS naboting;
USE naboting;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `naboting`
--

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `accessories`
--

CREATE TABLE `accessories` (
  `accessory_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `accessories`
--

INSERT INTO `accessories` (`accessory_id`, `item_id`, `name`) VALUES
(1, 1, 'Oplader'),
(2, 1, 'Ekstra batteri'),
(3, 2, 'Pløkker'),
(4, 2, 'Soveunderlag'),
(5, 4, 'Slange'),
(6, 4, 'Sæbekoncentrat'),
(7, 8, 'HDMI-kabel'),
(8, 8, 'Fjernbetjening'),
(9, 10, 'Regnslag'),
(10, 10, 'Sikkerhedssele'),
(11, 13, 'Pagaj'),
(12, 13, 'Redningsvest'),
(13, 13, 'Skørt');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `item_condition` varchar(50) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  `minimum_loan_period` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `items`
--

INSERT INTO `items` (`item_id`, `owner_id`, `title`, `brand`, `category`, `item_condition`, `quantity`, `minimum_loan_period`, `status`, `created_at`) VALUES
(1, 1, 'Boremaskine', 'Bosch', 'Værktøj', 'God', 1, 3, 'available', '2026-04-16 15:52:57'),
(2, 2, 'Telt', 'Outwell', 'Fritid', 'Meget god', 1, 2, 'available', '2026-04-16 15:52:57'),
(3, 1, 'Stige (3 meter)', 'Hailo', 'Værktøj', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(4, 1, 'Højtryksrenser', 'Kärcher', 'Udstyr', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(5, 1, 'Græsslåmaskine', 'Honda', 'Have', 'God', 1, 3, 'available', '2026-04-16 16:00:00'),
(6, 1, 'Campingstole', NULL, 'Fritid', 'God', 2, 1, 'available', '2026-04-16 16:00:00'),
(7, 1, 'Sovepose', 'Nordisk', 'Fritid', 'Meget god', 1, 1, 'available', '2026-04-16 16:00:00'),
(8, 1, 'Projektor', 'BenQ', 'Elektronik', 'Meget god', 1, 1, 'available', '2026-04-16 16:00:00'),
(9, 1, 'Røremaskine', 'KitchenAid', 'Køkken', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(10, 2, 'Cykelvogn', 'Thule', 'Transport', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(11, 2, 'Hækkeklipper', 'Bosch', 'Have', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(12, 2, 'Slibemaskine', 'Makita', 'Værktøj', 'God', 1, 2, 'available', '2026-04-16 16:00:00'),
(13, 2, 'Kajak', NULL, 'Fritid', 'Meget god', 1, 3, 'available', '2026-04-16 16:00:00'),
(14, 2, 'Yogamåtter', NULL, 'Sport', 'Ny', 2, 1, 'available', '2026-04-16 16:00:00'),
(15, 2, 'Airfryer', 'Philips', 'Køkken', 'Meget god', 1, 2, 'available', '2026-04-16 16:00:00'),
(16, 2, 'Elcykel', 'Trek', 'Transport', 'God', 1, 3, 'available', '2026-04-16 16:00:00');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `item_images`
--

CREATE TABLE `item_images` (
  `image_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `is_primary` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `item_images`
--

INSERT INTO `item_images` (`image_id`, `item_id`, `image_url`, `is_primary`) VALUES
(1, 1, 'images/boremaskine.jpg', 1),
(2, 2, 'images/telt.jpg', 1),
(3, 3, 'images/stige.jpg', 1),
(4, 4, 'images/hojtrykrenser.jpg', 1),
(5, 5, 'images/graesslasmaskine.jpg', 1),
(6, 6, 'images/campingstole.jpg', 1),
(7, 7, 'images/sovepose.jpg', 1),
(8, 8, 'images/projektor.jpg', 1),
(9, 9, 'images/roeremaskine.jpg', 1),
(10, 10, 'images/cykelvogn.jpg', 1),
(11, 11, 'images/haekkelipper.jpg', 1),
(12, 12, 'images/slibemaskine.jpg', 1),
(13, 13, 'images/kajak.jpg', 1),
(14, 14, 'images/yogamaatter.jpg', 1),
(15, 15, 'images/airfryer.jpg', 1),
(16, 16, 'images/elcykel.jpg', 1);

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `loans`
--

CREATE TABLE `loans` (
  `loan_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `borrower_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `loans`
--

INSERT INTO `loans` (`loan_id`, `item_id`, `borrower_id`, `start_date`, `end_date`, `status`, `created_at`) VALUES
(1, 1, 2, '2026-04-16', '2026-04-20', 'active', '2026-04-16 15:53:25');

-- --------------------------------------------------------

--
-- Struktur-dump for tabellen `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `user_type` varchar(50) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `profile_image_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Data dump for tabellen `users`
--

INSERT INTO `users` (`user_id`, `email`, `phone`, `password_hash`, `user_type`, `first_name`, `last_name`, `postal_code`, `city`, `profile_image_url`, `created_at`) VALUES
(1, 'anna@example.com', '12345678', 'hash123', 'private', 'Anna', 'Jensen', '2630', 'Tåstrup', NULL, '2026-04-16 15:52:33'),
(2, 'bo@example.com', '87654321', 'hash456', 'private', 'Bo', 'Nielsen', '4000', 'Roskilde', NULL, '2026-04-16 15:52:33');

--
-- Begrænsninger for dumpede tabeller
--

--
-- Indeks for tabel `accessories`
--
ALTER TABLE `accessories`
  ADD PRIMARY KEY (`accessory_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indeks for tabel `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indeks for tabel `item_images`
--
ALTER TABLE `item_images`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indeks for tabel `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`loan_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `borrower_id` (`borrower_id`);

--
-- Indeks for tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Brug ikke AUTO_INCREMENT for slettede tabeller
--

--
-- Tilføj AUTO_INCREMENT i tabel `accessories`
--
ALTER TABLE `accessories`
  MODIFY `accessory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Tilføj AUTO_INCREMENT i tabel `items`
--
ALTER TABLE `items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Tilføj AUTO_INCREMENT i tabel `item_images`
--
ALTER TABLE `item_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Tilføj AUTO_INCREMENT i tabel `loans`
--
ALTER TABLE `loans`
  MODIFY `loan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tilføj AUTO_INCREMENT i tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Begrænsninger for dumpede tabeller
--

--
-- Begrænsninger for tabel `accessories`
--
ALTER TABLE `accessories`
  ADD CONSTRAINT `accessories_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Begrænsninger for tabel `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`);

--
-- Begrænsninger for tabel `item_images`
--
ALTER TABLE `item_images`
  ADD CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Begrænsninger for tabel `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`),
  ADD CONSTRAINT `loans_ibfk_2` FOREIGN KEY (`borrower_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

--
-- Tilføj city og profile_image_url til users (hvis tabellen allerede eksisterer)
--
-- ALTER TABLE `users`
--   ADD COLUMN `city` varchar(100) DEFAULT NULL AFTER `postal_code`,
--   ADD COLUMN `profile_image_url` varchar(255) DEFAULT NULL AFTER `city`;

--
-- Trigger: sikrer at kun ét billede er primært per genstand
--

DELIMITER //
CREATE TRIGGER `ensure_single_primary_image`
BEFORE INSERT ON `item_images`
FOR EACH ROW
BEGIN
  IF NEW.is_primary = 1 THEN
    UPDATE `item_images` SET `is_primary` = 0 WHERE `item_id` = NEW.item_id;
  END IF;
END //
DELIMITER ;

--
-- Stored procedure: opret lån med tjek af tilgængelighed
--

DELIMITER //
CREATE PROCEDURE `CreateLoan`(
  IN p_item_id INT,
  IN p_borrower_id INT,
  IN p_start_date DATE,
  IN p_end_date DATE,
  IN p_message TEXT
)
BEGIN
  DECLARE v_status VARCHAR(50);

  SELECT `status` INTO v_status FROM `items` WHERE `item_id` = p_item_id;

  IF v_status != 'available' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Genstanden er ikke tilgængelig';
  ELSE
    INSERT INTO `loans` (`item_id`, `borrower_id`, `start_date`, `end_date`, `message`, `status`)
    VALUES (p_item_id, p_borrower_id, p_start_date, p_end_date, p_message, 'pending');

    SELECT LAST_INSERT_ID() AS `loan_id`;
  END IF;
END //
DELIMITER ;
