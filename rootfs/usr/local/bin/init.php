#!/usr/bin/env php
<?php

/*
 * Thanks to @clue:
 * https://github.com/clue/docker-ttrss/blob/master/configure-db.php
 */

class ConfigurationHelper
{
    /**
     * @param string $name
     * @param string $default
     *
     * @return string
     * @throws Exception
     */
    static public function getEnvironment($name, $default = null)
    {
        $value = getenv($name);

        if ($value !== false) {
            return $value;
        } elseif ($default !== null) {
            return $default;
        }

        throw new Exception(sprintf('Environment variable %s not set.', $name));
    }

    /**
     * @param array $configuration
     *
     * @return PDO
     */
    static public function getDatabase(array $configuration)
    {
        $pdo = new PDO(
            sprintf('mysql:dbname=%s;host=%s', $configuration['DB_NAME'], $configuration['DB_HOST']),
            $configuration['DB_USER'],
            $configuration['DB_PASS']
        );
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        return $pdo;
    }

    /**
     * @param array $configuration
     *
     * @return bool
     * @throws PDOException
     */
    static public function testConnect(array $configuration)
    {
        for ($i = 0; $i < 5; $i++) {
            try {
                self::getDatabase($configuration);

                return true;
            } catch (PDOException $e) {
                sleep(5);
            }
        }

        throw $e;
    }

    /**
     * @param array $configuration
     *
     * @return void
     */
    static public function saveConfiguration(array $configuration)
    {
        $contents = file_get_contents('/var/www/html/config.php-dist');
        foreach ($configuration as $name => $value) {
            $contents = preg_replace(
                '/(define\s*\(\'' . $name . '\',\s*)(.*)(\);)/',
                '$1"' . $value . '"$3',
                $contents
            );
        }

        $contents .= 'umask(0000);';
        file_put_contents('/tmp/config.php', $contents);
    }
}

$config = [
    'SELF_URL_PATH' => ConfigurationHelper::getEnvironment('SELF_URL_PATH', 'http://localhost'),
    'DB_TYPE'       => 'mysql',
    'DB_HOST'       => ConfigurationHelper::getEnvironment('DB_HOST'),
    'DB_PORT'       => ConfigurationHelper::getEnvironment('DB_PORT', '3306'),
    'DB_NAME'       => ConfigurationHelper::getEnvironment('DB_NAME'),
    'DB_USER'       => ConfigurationHelper::getEnvironment('DB_USER'),
    'DB_PASS'       => ConfigurationHelper::getEnvironment('DB_PASS'),
];

if (ConfigurationHelper::testConnect($config)) {
    $pdo = ConfigurationHelper::getDatabase($config);

    try {
        $pdo->query('SELECT 1 FROM ttrss_feeds');
    } catch (PDOException $e) {
        $schema = file_get_contents('schema/ttrss_schema_mysql.sql');
        $schema = preg_replace('/--(.*?);/', '', $schema);
        $schema = preg_replace('/[\r\n]/', ' ', $schema);
        $schema = trim($schema, ' ;');

        foreach (explode(';', $schema) as $stm) {
            $pdo->exec($stm);
        }
    }
}

ConfigurationHelper::saveConfiguration($config);
