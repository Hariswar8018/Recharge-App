// Test simulation for 2x2 Auto-Fill Spillover Matrix (6 Levels)
// Simulates 127 members (Top ID + 126 downlines) and verifies all payouts

function runSimulation() {
  const members = {}; // matrix_index -> { id, cycle_id, members_count, income, levelEarnings: {} }

  // 127 members: Top ID = 1, downlines = 2 to 127
  for (let k = 1; k <= 127; k++) {
    members[k] = {
      matrix_index: k,
      members_count: 0,
      income: 0,
      levelEarnings: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0 }
    };

    if (k > 1) {
      let curr = k;
      for (let depth = 1; depth <= 6; depth++) {
        const uplineIndex = Math.floor(curr / 2);
        if (uplineIndex < 1) break;

        const upline = members[uplineIndex];
        if (upline.members_count < 126) {
          upline.members_count += 1;
          upline.income += 100;
          upline.levelEarnings[depth] += 100;
        }

        curr = uplineIndex;
      }
    }
  }

  console.log('=== 2x2 AUTO-FILL SPILLOVER MATRIX SIMULATION RESULTS ===');
  console.log('Top ID (pos 1):', {
    members_count: members[1].members_count,
    total_income: members[1].income,
    breakdown: members[1].levelEarnings
  });

  console.log('\nLevel 1 IDs (pos 2, 3):', {
    pos2: { members: members[2].members_count, income: members[2].income, breakdown: members[2].levelEarnings },
    pos3: { members: members[3].members_count, income: members[3].income, breakdown: members[3].levelEarnings }
  });

  console.log('\nLevel 2 IDs (pos 4, 5, 6, 7):', {
    pos4: { members: members[4].members_count, income: members[4].income, breakdown: members[4].levelEarnings },
    pos5: { members: members[5].members_count, income: members[5].income, breakdown: members[5].levelEarnings },
    pos6: { members: members[6].members_count, income: members[6].income, breakdown: members[6].levelEarnings },
    pos7: { members: members[7].members_count, income: members[7].income, breakdown: members[7].levelEarnings }
  });

  console.log('\nLevel 3 sample (pos 8):', {
    members: members[8].members_count,
    income: members[8].income,
    breakdown: members[8].levelEarnings
  });

  console.log('\nLevel 4 sample (pos 16):', {
    members: members[16].members_count,
    income: members[16].income,
    breakdown: members[16].levelEarnings
  });

  console.log('\nLevel 5 sample (pos 32):', {
    members: members[32].members_count,
    income: members[32].income,
    breakdown: members[32].levelEarnings
  });

  console.log('\nLevel 6 sample (pos 64):', {
    members: members[64].members_count,
    income: members[64].income,
    breakdown: members[64].levelEarnings
  });

  let totalPayout = 0;
  for (let k = 1; k <= 127; k++) {
    totalPayout += members[k].income;
  }

  const levelPoolCollection = 126 * 600;
  const levelPoolSurplus = levelPoolCollection - totalPayout;
  const directCollection = 126 * 300;
  const companyMaintenance = 126 * 300;
  const totalCompanyEarnings = levelPoolSurplus + companyMaintenance;

  console.log('\n=== FINANCIAL RECONCILIATION ===');
  console.log('Total Level Payout to all 127 users:', totalPayout, '(Expected: 64200)');
  console.log('Level Pool Collection (126 * 600):', levelPoolCollection, '(Expected: 75600)');
  console.log('Level Pool Surplus (75600 - 64200):', levelPoolSurplus, '(Expected: 11400)');
  console.log('Direct Income Collection (126 * 300):', directCollection, '(Expected: 37800)');
  console.log('Company Maintenance (126 * 300):', companyMaintenance, '(Expected: 37800)');
  console.log('Total Company Earning (11400 + 37800):', totalCompanyEarnings, '(Expected: 49200)');

  const assert = require('assert');
  assert.strictEqual(members[1].income, 12600, 'Top ID income must be 12600');
  assert.strictEqual(members[2].income, 6200, 'Pos 2 income must be 6200');
  assert.strictEqual(members[4].income, 3000, 'Pos 4 income must be 3000');
  assert.strictEqual(members[5].income, 3000, 'Pos 5 income must be 3000');
  assert.strictEqual(members[6].income, 3000, 'Pos 6 income must be 3000');
  assert.strictEqual(members[7].income, 3000, 'Pos 7 income must be 3000');
  assert.strictEqual(members[8].income, 1400, 'Pos 8 income must be 1400');
  assert.strictEqual(members[16].income, 600, 'Pos 16 income must be 600');
  assert.strictEqual(members[32].income, 200, 'Pos 32 income must be 200');
  assert.strictEqual(members[64].income, 0, 'Pos 64 income must be 0');
  assert.strictEqual(totalPayout, 64200, 'Total payout must be 64200');
  assert.strictEqual(levelPoolSurplus, 11400, 'Surplus must be 11400');
  assert.strictEqual(totalCompanyEarnings, 49200, 'Total company earnings must be 49200');

  console.log('\n>>> ALL 12 ASSERTIONS PASSED WITH 100% ACCURACY! <<<');
}

runSimulation();
