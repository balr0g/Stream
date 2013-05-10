//
//  StBlock.m
//  temp
//
//  Created by tim lindner on 5/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "StBlock.h"
#import "StBlock.h"
#import "StStream.h"
#import "Analyzation.h"
#import "HexFiendAnaylizer.h"
#import "TextAnaylizer.h"

@implementation StBlock

@dynamic offset;
@dynamic name;
@dynamic length;
@dynamic repeat;
@dynamic expectedSize;
@dynamic checkBytes;
@dynamic uiCheckBytes;
@dynamic uiData;
@dynamic isEdit;
@dynamic isFail;
@dynamic markForDeletion;
@dynamic source;
@dynamic uiName;
@dynamic valueTransformer;
@dynamic blocks;
@dynamic parentBlock;
@dynamic parentStream;
@dynamic sourceSubStreamParent;
@dynamic editSet;
@dynamic attributeColor;
@synthesize blocksArray;

- (NSArray *)blocksArray
{
    return [self.blocks array];
}

- (void)awakeFromInsert
{
    self.optionsDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    dataIndex = attrIndex = depIndex = 0;
}

- (void)awakeFromFetch
{
    if (self.parentBlock == nil) {
        StBlock *subBlock;
        
        subBlock = [self subBlockNamed:@"data"];
        if (subBlock != nil) {
            dataIndex = [subBlock.blocks count];
        }
        else {
            dataSubBlock = subBlock;
            dataIndex = 0;
        }
        
        subBlock = [self subBlockNamed:@"attributes"];
        if (subBlock != nil) {
            attrIndex = [subBlock.blocks count];
        }
        else {
            attrSubBlock = subBlock;
            attrIndex = 0;
        }
        
        subBlock = [self subBlockNamed:@"dependencies"];
        if (subBlock != nil) {
            depSubBlock = subBlock;
            depIndex = [subBlock.blocks count];
        }
        else {
            depIndex = 0;
        }
        
    }
}

- (StStream *)getStream
{
    if( self.parentStream != nil )
        return self.parentStream;
    else
        return [self.parentBlock getStream];
}

- (void) addAttributeRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name
{
    [self addAttributeRange:blockName start:start length:length name:name verification:nil transformation:nil];
}

- (void) addAttributeRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify
{
    [self addAttributeRange:blockName start:start length:length name:name verification:verify transformation:nil];
}

- (void) addAttributeRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify transformation:(NSString *)transform
{
    StBlock *attrBlock = attrSubBlock; //[self subBlockNamed:@"attributes"];
    
    if (attrBlock == nil) {
        attrBlock = [NSEntityDescription insertNewObjectForEntityForName:@"StBlock" inManagedObjectContext:self.managedObjectContext];
        attrBlock.name = @"attributes";
        attrBlock.sourceUTI = @"org.macmess.stream.attribute";
        attrBlock.currentEditorView = @"Block Attribute View";
        [self addSubBlocksObject:attrBlock];
        attrSubBlock = attrBlock;
    }

    NSOrderedSet  *attrBlocks = attrBlock.blocks;
    StBlock *newBlock;
    
    if (attrIndex < [attrBlocks count]) {
        newBlock = [attrBlocks objectAtIndex:attrIndex];
        newBlock.markForDeletion = NO;
        newBlock.isEdit = NO;
        newBlock.isFail = NO;
        newBlock.resultingData = nil;
    }
    else
    {
        newBlock = [NSEntityDescription insertNewObjectForEntityForName:@"StBlock" inManagedObjectContext:self.managedObjectContext];
        [attrBlock addSubBlocksObject:newBlock];
//        [attrBlock addBlocksObject:newBlock];
    }
    
    newBlock.name = [NSString stringWithFormat:@"%d: %@, %d, %d", attrIndex, blockName, start, length];
    newBlock.source = blockName;
    newBlock.uiName = name;
    newBlock.offset = start;
    newBlock.length = length;
    newBlock.checkBytes = verify;
    newBlock.valueTransformer = transform;
    
//    [self checkEdited:newBlock];
//    [self checkFail:newBlock];
    attrIndex++;
    self.resultingData = nil;
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length
{
    [self addDataRange:blockName start:start length:length name:nil verification:nil transformation:nil expectedLength:length repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length expectedLength:(NSUInteger)expectedLength
{
    [self addDataRange:blockName start:start length:length name:nil verification:nil transformation:nil expectedLength:expectedLength repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length expectedLength:(NSUInteger)expectedLength repeat:(BOOL)repeat
{
    [self addDataRange:blockName start:start length:length name:nil verification:nil transformation:nil expectedLength:expectedLength repeat:repeat];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name
{
    [self addDataRange:blockName start:start length:length name:name verification:nil transformation:nil expectedLength:length repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify
{
    [self addDataRange:blockName start:start length:length name:name verification:verify transformation:nil expectedLength:length repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name transformation:(NSString *)transform
{
    [self addDataRange:blockName start:start length:length name:name verification:nil transformation:transform expectedLength:length repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify transformation:(NSString *)transform
{
    [self addDataRange:blockName start:start length:length name:name verification:verify transformation:transform expectedLength:length repeat:NO];
}

- (void) addDataRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify transformation:(NSString *)transform expectedLength:(NSUInteger)expectedLength repeat:(BOOL)repeat
{
    StBlock *dataBlock = dataSubBlock; //[self subBlockNamed:@"data"];
    
    if (dataBlock == nil) {
        dataBlock = [NSEntityDescription insertNewObjectForEntityForName:@"StBlock" inManagedObjectContext:self.managedObjectContext];
        dataBlock.name = @"data";
        dataBlock.sourceUTI = @"public.data";
        [self addSubBlocksObject:dataBlock];
        dataSubBlock = dataBlock;
    }
    
    NSOrderedSet  *dataBlocks = dataBlock.blocks;
    StBlock *newBlock;
    
    if (dataIndex < [dataBlocks count]) {
        newBlock = [dataBlocks objectAtIndex:dataIndex];
        newBlock.markForDeletion = NO;
        newBlock.isEdit = NO;
        newBlock.isFail = NO;
        newBlock.resultingData = nil;
    }
    else
    {
        newBlock = [NSEntityDescription insertNewObjectForEntityForName:@"StBlock" inManagedObjectContext:self.managedObjectContext];
        [dataBlock addSubBlocksObject:newBlock];
//        [dataBlock addBlocksObject:newBlock];
    }
    
    newBlock.name = [NSString stringWithFormat:@"%d: %@, %d, %d", dataIndex, blockName, start, length];
    newBlock.uiName = name;
    newBlock.source = blockName;
    newBlock.offset = start;
    newBlock.length = length;
    newBlock.checkBytes = verify;
    newBlock.valueTransformer = transform;
    newBlock.repeat = repeat;
    newBlock.expectedSize = expectedLength;
    self.expectedSize += expectedLength;
    
//    [self checkEdited:newBlock];
//    [self checkFail:newBlock];
    dataIndex++;
    self.resultingData = nil;
}

- (void) addDependenciesRange:(NSString *)blockName start:(NSUInteger)start length:(NSUInteger)length name:(NSString *)name verification:(NSData *)verify transformation:(NSString *)transform
{
    StBlock *depBlock = depSubBlock; //[self subBlockNamed:@"dependencies"];
    
    if (depBlock == nil) {
        depBlock = [NSEntityDescription insertNewObjectForEntityForName:@"dependencies" inManagedObjectContext:self.managedObjectContext];
        depBlock.name = @"data";
        depBlock.sourceUTI = @"public.data";
        [self addSubBlocksObject:depBlock];
        depSubBlock = depBlock;
    }
    
    NSOrderedSet  *depBlocks = depBlock.blocks;
    StBlock *newBlock;
    
    if (depIndex < [depBlocks count]) {
        newBlock = [depBlocks objectAtIndex:depIndex];
        newBlock.markForDeletion = NO;
        newBlock.isEdit = NO;
        newBlock.isFail = NO;
        newBlock.resultingData = nil;
    }
    else
    {
        newBlock = [NSEntityDescription insertNewObjectForEntityForName:@"StBlock" inManagedObjectContext:self.managedObjectContext];
        [depBlock addSubBlocksObject:newBlock];
//        [depBlock addBlocksObject:newBlock];
    }
    
    newBlock.name = [NSString stringWithFormat:@"%d: %@, %d, %d", depIndex, blockName, start, length];
    newBlock.uiName = name;
    newBlock.source = blockName;
    newBlock.offset = start;
    newBlock.length = length;
    newBlock.checkBytes = verify;
    newBlock.valueTransformer = transform;
    self.expectedSize += length;
    
//    [self checkEdited:newBlock];
//    [self checkFail:newBlock];
    depIndex++;
    self.resultingData = nil;
}

- (StBlock *)subBlockNamed:(NSString *)inName
{
    for (StBlock *aBlock in self.blocks) {
        if ([aBlock.name isEqualToString:inName]) {
            return aBlock;
        }
    }
    
    return nil;
}

- (void) checkEdited:(StBlock *)newBlock
{
    if( [newBlock.source isEqualToString:@"stream"] )
    {
        if( [[[self getStream] lastFilterAnayliser] streamEditedInRange:NSMakeRange(newBlock.offset, newBlock.length)] )
        {
            [newBlock smartSetEdit];
        }
    }
    else if( [[self getStream] isBlockEdited:newBlock.source] )
    {
        [newBlock smartSetEdit];
    }
}

- (void) checkFail:(StBlock *)newBlock
{
    if( newBlock.checkBytes != nil )
    {
        if( ![newBlock.checkBytes isEqualToData:[newBlock resultingData]] )
        {
            [newBlock smartSetFail];
        }
    }
    
    if( ![newBlock.source isEqualToString:@"stream"] )
    {
        if( [[self getStream] isBlockFailed:newBlock.source] )
        {
            [newBlock smartSetFail];
        }
    }
}

- (StBlock *)subBlockAtIndex:(NSUInteger)theIndex
{
    NSOrderedSet *blocksSet = self.blocks;
    
    if( theIndex < [blocksSet count] )
    {
        return [blocksSet objectAtIndex:theIndex];
    }
    
    return nil;
}

- (NSValue *)unionRange
{
    /* This returns the largest range that encompasses all of child blocks */
    
    NSRange result = {0, 0};
    NSValue *_unionRange = [self primitiveUnionRange];

    if (_unionRange == nil) {
        if( self.source == nil )
        {
            if( self.parentStream != nil )
            {
                /* This is a top level block, try to return range from data & attributes block */
                NSRange dataRange = [[dataSubBlock unionRange] rangeValue];
                
                NSRange attributeRange = [[attrSubBlock unionRange] rangeValue];
                
                if (dataRange.length == 0 && attributeRange.length != 0) {
                    result = attributeRange;
                } else if (dataRange.length != 0 && attributeRange.length == 0) {
                    result = dataRange;
                } else {
                    result = NSUnionRange(attributeRange, dataRange);
                }
            }
            else
            {
                /* This is a midlevel block, return it's accumulated blocks */
                for (StBlock *theBlock in self.blocks)
                {
                    if( result.location == 0 && result.length == 0 )
                        result = [[theBlock unionRange] rangeValue];
                    else {
                        result = NSUnionRange( result, [[theBlock unionRange] rangeValue] );
                    }
                }
            }
        }
        else
        {
            /* This is a leaf block */
            
            if( [[self source] isEqualToString:@"stream"] )
            {
                result = NSMakeRange(self.offset, self.length);
            }
            else
            {
                NSRange fullRange = [[[[self getStream] topLevelBlockNamed:self.source] unionRange] rangeValue];
                NSUInteger useLength = self.length;
                
                if (useLength == 0) {
                    useLength = (fullRange.location + fullRange.length) - (fullRange.location + self.offset);
                }
                
                result = NSMakeRange(fullRange.location + self.offset, useLength);
            }
        }
    }
    else {
        return _unionRange;
    }
    
    _unionRange = [NSValue valueWithRange:result];
    [self setPrimitiveUnionRange:_unionRange];
    return _unionRange;
}

- (BOOL) topLevelBlock
{
    if( self.source == nil )
    {
        if( self.parentStream != nil )
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSData *)resultingData
{
    NSMutableData *result;
    NSData *_resultingData = [self primitiveResultingData];// [self primitiveValueForKey:@"resultingData"];
    
    if (_resultingData == nil)
    {
//        NSLog( @"resulting data miss for: %@", self );
        if( self.source == nil )
        {
            if( self.parentStream != nil )
            {
                /* This is a top level block, return data from data block */
                result = (NSMutableData *)[dataSubBlock resultingData];
            }
            else
            {
                /* This is a midlevel block, return it's accumulated blocks */
                result = [[[NSMutableData alloc] init] autorelease];
                
                for (StBlock *theBlock in self.blocks)
                {
                    NSData *subBlockData = [theBlock resultingData];
                    [result appendData:subBlockData];
                }
            }
        }
        else
        {
            /* This is a leaf block */
            StStream *ourStream = [self getStream];
            NSData *blockData = [ourStream dataOfTopLevelBlockNamed:self.source];
            NSUInteger useLength;
            
            if( self.length == 0 )
            {
                /* length of zero means "to the end of the block" */
                useLength = [blockData length] - self.offset;
            }
            else
                useLength = self.length;
            
            NSRange theRange = NSMakeRange(self.offset, useLength);
            result = [[blockData subdataWithRange:theRange] mutableCopy];
            
            NSUInteger exSz = self.expectedSize;
            
            if (self.repeat) {
                while ([result length] < exSz) {
                    [result appendData:result];
                }
                
                [result setLength:exSz];
            }
            
            [result autorelease];
        }

//        [self setPrimitiveValue:result forKey:@"resultingData"];
        [self setPrimitiveResultingData:result];
    }
    else {
        result = (NSMutableData *)_resultingData;
    }
    
    return result;
}

- (NSData *)getAttributeData
{
    return [attrSubBlock resultingData];
}

- (id)getAttributeDatawithUIName:(NSString *)name
{
    for (StBlock *aBlock in [attrSubBlock blocks])
    {
        if( [aBlock.uiName isEqualToString:name] )
        {
            if (aBlock.valueTransformer != nil) {
                NSValueTransformer *tf = [NSValueTransformer valueTransformerForName:aBlock.valueTransformer];
                
                if (tf != nil) {
                    return [tf transformedValue:[aBlock resultingData]];
                }
                else {
                    return [aBlock resultingData];
                }
            }
            else {
                return [aBlock resultingData];
            }
        }
    }
    return nil;
}

- (NSString *)description
{
    if( self.source == nil )
    {
        if( self.parentStream != nil )
        {
            return [NSString stringWithFormat:@"%p: Top level block named: %@", self, [self name]];
        }
        else
        {
            return [NSString stringWithFormat:@"%p: Mid level block:%@, named: %@", self, [[self parentBlock] name], [self name]];
        }
    }
    else
    {
        NSUInteger index = [self.parentBlock.blocks indexOfObject:self];
        return [NSString stringWithFormat:@"%p: Leaf block: %@, named: %@, index: %d, source: %@, start: %d, lenth: %d", self, [[[self parentBlock] parentBlock] name], [[self parentBlock] name], index, [self source], self.offset, self.length];
    }
}

- (NSOrderedSet *)getOrderedSetOfBlocks
{
    NSOrderedSet *result;
    
    if( self.source == nil )
    {
        if( self.parentStream != nil )
        {
            /* This is a top level block, return blocks from data block */
            result = [dataSubBlock getOrderedSetOfBlocks];
        }
        else
        {
            /* This is a midlevel block, return it's accumulated blocks */
            result = self.blocks;
        }
    }
    else
    {
        /* This is a leaf block */
        result = [NSOrderedSet orderedSetWithObject:self];
    }
    
    return result;
}

- (BOOL) writeByte:(unsigned char)byte atOffset:(NSUInteger)offset
{
    NSOrderedSet *blockSet = [self getOrderedSetOfBlocks];
    NSUInteger place = 0;
    BOOL byteWritten = NO;
    
    [self smartSetEdit];
    
    for (StBlock *aBlock in blockSet)
    {
        if( offset < place + aBlock.length )
        {
            /* we found the block to write to */
            if( [aBlock.source isEqualToString:@"stream"] )
            {
                /* writing to stream */
                [[[self getStream] lastFilterAnayliser] writebyte:byte atOffset:aBlock.offset + (offset - place)];
                byteWritten = YES;
                break;
            }
            else
            {
                StBlock *subBlock = [[self getStream] topLevelBlockNamed:aBlock.source];
                byteWritten = [subBlock writeByte:byte atOffset:offset - place];
            }
        }
        else
            place += aBlock.length;
    }
    
    NSAssert(byteWritten == YES, @"Tried writing byte past end of block: %@, offset: %d", [self source], [self offset]);
    return byteWritten;
}

- (void) smartSetEdit
{
    if( self.source == nil )
    {
        if( self.parentStream != nil )
        {
            /* top-level block */
            self.isEdit = YES;
        }
        else
        {
            /* mid-level block */
            self.isEdit = self.parentBlock.isEdit = YES;
        }
    }
    else
    {
        /* leaf block */
        self.isEdit = self.parentBlock.isEdit = self.parentBlock.parentBlock.isEdit = YES;
    }
}

- (void) smartSetFail
{
    if( self.source == nil )
    {
        if( self.parentStream != nil )
        {
            /* top-level block */
            self.isFail = YES;
        }
        else
        {
            /* mid-level block */
            self.isFail = self.parentBlock.isFail = YES;
        }
    }
    else
    {
        /* leaf block */
        self.isFail = self.parentBlock.isFail = self.parentBlock.parentBlock.isFail = YES;
        
        if( [self.source isEqualToString:@"stream"] )
        {
            NSRange range = {self.offset, self.length};
            [[[self getStream] lastFilterAnayliser].failIndexSet addIndexesInRange:range];
        }
        
    }
}

- (NSDictionary *)uiData
{
    NSDictionary *result = nil;
    
    if( self.resultingData != nil )
        result = [NSDictionary dictionaryWithObjectsAndKeys: self.resultingData, @"value", self.valueTransformer, @"valueTransformer", @"data", @"key", [self objectID], @"objectID", nil];
    
    return result;
}

- (void)addSubBlocksObject:(StBlock *)value
{
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"blocks"];
    [tempSet addObject:value];
//    self.blocks = tempSet;
}

- (void) setUiData:(NSDictionary *)dictionary
{
    /* parse string and pass change up the block chain */
    NSString *mode = [dictionary objectForKey:@"mode"];
    id value = [dictionary objectForKey:@"value"];
    
    NSValueTransformer *vt = [NSValueTransformer valueTransformerForName:self.valueTransformer];
    
    if( [[[vt class] transformedValueClass] isSubclassOfClass:[NSNumber class]] )
    {
        NSString *string = value;
        
        if( [string hasPrefix:@"0x"] )
            mode = @"Hexadecimal";
        
        NSUInteger result = 0;
        
        if( [mode isEqualToString:@"Hexadecimal"] )
        {
            /* convert number from hexidecimal to decimal */
            unsigned long long tempResult;
            [[NSScanner scannerWithString: string] scanHexLongLong:&tempResult];
            value = [NSNumber numberWithUnsignedLongLong:tempResult];
        }
        else
        {
            result = [value integerValue];
            value = [NSNumber numberWithUnsignedInteger:result];
        }
    }
    
    NSData *theData = [vt reverseTransformedValue:value ofSize:[self length]];
    
    [[self getStream] setBlock:self withData:theData];
}

- (NSDictionary *)uiCheckBytes
{
    NSDictionary *result = nil;
    
    if( self.checkBytes != nil )
        result = [NSDictionary dictionaryWithObjectsAndKeys: self.checkBytes, @"value", self.valueTransformer, @"valueTransformer", @"checkBytes", @"key", [self objectID], @"objectID", nil];
    
    return result;
}

- (NSColor *)attributeColor
{
    NSColor *_attributeColor = [self primitiveAttributeColor];
    
    if (_attributeColor == nil) {
        [self checkEdited:self];
        [self checkFail:self];

        if( self.isEdit && self.isFail )
            return [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:0.5];
        else if( self.isEdit )
            return [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5];
        else if( self.isFail )
            return [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        else {
            _attributeColor = [NSColor clearColor];
        }
        
        [self setPrimitiveAttributeColor:_attributeColor];
    }
    
    return _attributeColor;
}

- (NSMutableIndexSet *)editSet
{
    NSMutableIndexSet *indexSet;
    
    indexSet = [self primitiveEditSet];
    
    if (indexSet == nil) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        if( self.source == nil )
        {
            if( self.parentStream != nil )
            {
                /* top level block */
                [indexSet addIndexes:[dataSubBlock editSet]];
            }
            else
            {
                /* mid level block */
                NSInteger shiftAmount = 0;
                
                for (StBlock *aBlock in self.blocks)
                {
                    NSMutableIndexSet *set = [aBlock editSet];
                    [set shiftIndexesStartingAtIndex:0 by:shiftAmount];
                    [indexSet addIndexes:set];
                    shiftAmount += aBlock.length;
                }
            }
        }
        else
        {
            /* leaf block */
            if( [self.source isEqualToString:@"stream"] )
            {
                NSRange range = {self.offset, self.length};
                StAnaylizer *lastFilterAnaylizer = [[self getStream] lastFilterAnayliser];
                NSIndexSet *set = lastFilterAnaylizer.editIndexSet;
                NSMutableIndexSet *setInRange = [[set indexesInRange:range options:0 passingTest:
                                                  ^(NSUInteger idx, BOOL *stop){
    #pragma unused(idx)
    #pragma unused(stop)
                                                      return YES; }] mutableCopy];
                [setInRange shiftIndexesStartingAtIndex:0 by:-self.offset];
                [indexSet addIndexes:setInRange];
                [setInRange release];
            }
            else
            {
                NSRange range;
                
                if( self.length == 0 )
                {
                    StStream *ourStream = [self getStream];
                    NSData *blockData = [ourStream dataOfTopLevelBlockNamed:self.source];
                    range = NSMakeRange( self.offset, [blockData length] - self.offset );
                }
                else
                    range = NSMakeRange( self.offset, self.length );
                
                NSMutableIndexSet *set = [[[self getStream] topLevelBlockNamed:self.source] editSet];
                NSMutableIndexSet *setInRange = [[set indexesInRange:range options:0 passingTest:
                                                  ^(NSUInteger idx, BOOL *stop){
    #pragma unused(idx)
    #pragma unused(stop)
                                                      return YES; }] mutableCopy];
                [setInRange shiftIndexesStartingAtIndex:0 by:-self.offset];
                [indexSet addIndexes:setInRange];
                [setInRange release];
            }
        }
        [self setPrimitiveEditSet:[indexSet autorelease]];
        return indexSet;
    }
    else {
        return indexSet;
    }
}

- (void)setMarkForDeletion:(BOOL)del
{
    NSValue *mfd = [NSNumber numberWithBool:del];
    [self setPrimitiveValue:mfd forKey:@"markForDeletion"];
    self.attributeColor = nil;
    self.resultingData = nil;
}

- (void)willTurnIntoFault
{
    self.anaylizerObject = nil;
    self.resultingData = nil;
    self.attributeColor = nil;
}

- (BOOL) canChangeEditor
{
    return YES;
}

- (void) resetCounters
{
    dataIndex = attrIndex = depIndex = 0;
}

+ (NSSet *)keyPathsForValuesAffectingAttributeColor
{
    return [NSSet setWithObjects:@"isEdit", @"isFail", nil];
}

+ (NSSet *)keyPathsForValuesAffectingUiCheckBytes
{
    return [NSSet setWithObjects:@"checkBytes", @"valueTransformer", nil];
}

+ (NSSet *)keyPathsForValuesAffectingUiData
{
    return [NSSet setWithObjects:@"data", @"valueTransformer", nil];
}

@end

@implementation StBlockFormatter

@synthesize mode;

- (NSString *)stringForObjectValue:(id)anObject
{
    id result;
    
    if( [anObject isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary *inDict = anObject;
        NSString *valueTransformerString = [inDict objectForKey:@"valueTransformer"];
        
        if( valueTransformerString == nil )
        {
            /* a dictionary without a value transformer is from the reverse formatter */
            result = [inDict objectForKey:@"value"];
        }
        else
        {
            /* a dictionary with no value transformer is straight from the block object */
            NSValueTransformer *vt = [NSValueTransformer valueTransformerForName:valueTransformerString];
            result = [vt transformedValue:[inDict objectForKey:@"value"]];
            
            if( ![result isKindOfClass:[NSString class]] )
            {
                if( [self.mode isEqualToString:@"Decimal"] )
                    result = [result stringValue];
                else
                {
                    result = [NSString stringWithFormat:@"0x%x", [result intValue]];
                }
            }
        }
    }
    else if( [anObject isKindOfClass:[NSString class]] )
    {
        result = anObject;
    }
    else
        result = nil;
    
    return result;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
#pragma unused(error)
    if( [[string class] isSubclassOfClass:[NSString class]] )
    {
        /* just send the string back, we'll parse in the StBlock */
        *anObject = [NSDictionary dictionaryWithObjectsAndKeys:mode, @"mode", string, @"value", nil];
        return YES;
    }
    else
    {
        NSLog( @"Incomming string not string: %@", string );
        return NO;
    }
}

@end

