'use client'

import { useTable, useFlexLayout } from 'react-table';
import { useMemo } from 'react';

export default function RnrUnit(){

    function Table({ columns, data }) {
        const {
          getTableProps,
          getTableBodyProps,
          headerGroups,
          rows,
          prepareRow,
        } = useTable(
          {
            columns,
            data,
          },
          useFlexLayout
          // 테이블 컬럼 너비를 자유롭게 조절하기 위해 Flex Layout 사용
        );



    
        const Clicktest = ()=>{
            console.log("클릭이벤트");
        }
      


        // 테이블 렌더링
        return (
        <div className="reception">
        
          <div>
          <table {...getTableProps()}>
            <thead>
              {headerGroups.map(headerGroup => (
                <tr {...headerGroup.getHeaderGroupProps()}>
                  {headerGroup.headers.map(column => (
                    <th {...column.getHeaderProps()}>{column.render('Header')}</th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody {...getTableBodyProps()}>
              {rows.map(row => {
                prepareRow(row);
                return (
                    <tr {...row.getRowProps()}>
                      {row.cells.map(cell => {
                        // Check if the column accessor is 'management' and render an image if it is
                        if (cell.column.id === 'management') {
                          return (
                            <td {...cell.getCellProps()}>
                              <img src="/GDR/decide_normal.png" alt="Management" />
                            </td>
                          );
                        }
                        return <td onDoubleClick={Clicktest} {...cell.getCellProps()}>{cell.render('Cell')}</td>;
                      })}
                  </tr>
                );
              })}
            </tbody>
          </table>
          </div>
          </div>
        );
      }


    const columns = useMemo(
        () => [
            {
                Header: '관리',
                accessor: 'management',
                width: 60,
              },
              {
                Header: '수단',
                accessor: 'method',
                width: 80,
              },
              {
                Header: '환자 유형',
                accessor: 'patientType',
                width: 80
              },
              {
                Header: '이름',
                accessor: 'name',
                width: 80,
              },
              {
                Header: '진료실',
                accessor: 'treatmentRoom',
                width: 100
              },
              {
                Header: '주민번호',
                accessor: 'residentRegistrationNumber',
                width: 150
              },
              {
                Header: '내원 목적',
                accessor: 'purposeOfVisit',
                width: 80
              },
              {
                Header: '요청 시각',
                accessor: 'confirmationTime',
                width: 80
              },
            ],
        []
      );
    
      const data = useMemo(
        () => [
            {
                id: 1,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철수',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1234567',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:00',
              },
              {
                id: 2,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 3,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 4,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 5,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 6,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 7,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
              {
                id: 8,
                management: '관리',
                method: '태블릿',
                patientType: '재진',
                name: '김철우',
                treatmentRoom: '내과',
                residentRegistrationNumber: '123456-1245678',
                purposeOfVisit: '진료',
                confirmationTime: '04-30 10:05',
              },
          // 여기에 데이터를 넣어주세요
        ],
        []
      );
    
      return <Table columns={columns} data={data} />;
    }