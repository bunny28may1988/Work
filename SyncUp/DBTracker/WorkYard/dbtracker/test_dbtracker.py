import unittest
import csv
from unittest.mock import patch
from io import StringIO
from main import process_dml_statements


class TestProcessDMLStatements(unittest.TestCase):
    def test_process_dml_statements(self):
        dml_matches = [
           
            "2022-01-02T12:00:00.000Z SQL> UPDATE table2 SET column2 = 'value2'; 1 row updated"
           
        ]
        expected_output = [           
           
            ['', '', '', '', '', '', '','UPDATE', "SQL> UPDATE table2 SET column2 = 'value2';", '1', '2022-01-02T12:00:00.000Z']           
        ]
        
        output = StringIO()
        csvwriter = csv.writer(output)
        process_dml_statements(dml_matches, csvwriter)
        result = [line.strip().split(',') for line in output.getvalue().strip().split('\n')]
        print(result)
        self.assertEqual(result, expected_output)

    def test_process_insert_statements(self):
        dml_matches = [
           
            "2022-01-02T12:00:00.000Z SQL> INSERT INTO table1 (column1) VALUES ('value1'); 1 row inserted"           
        ]
        expected_output = [           
           
            ['', '', '', '', '', '', '','INSERT', "SQL> INSERT INTO table1 (column1) VALUES ('value1');", '1', '2022-01-02T12:00:00.000Z']            
        ]
        
        output = StringIO()
        csvwriter = csv.writer(output)
        process_dml_statements(dml_matches, csvwriter)
        result = [line.strip().split(',') for line in output.getvalue().strip().split('\n')]
        self.assertEqual(result, expected_output)

if __name__ == '__main__':
    unittest.main()